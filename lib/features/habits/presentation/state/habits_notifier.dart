import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dopamine_budget/features/habits/domain/entities/habit.dart';
import 'package:dopamine_budget/features/habits/domain/repositories/habit_repository.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/features/actions/domain/usecases/add_action_usecase.dart';
import 'package:dopamine_budget/core/sync/sync_service.dart';
import 'package:dopamine_budget/core/widget/widget_data_service.dart';

// lib/features/habits/presentation/state/habits_notifier.dart

/// Single Source of Truth для справочника привычек и их привязки к сессии.
///
/// Подписывается на:
/// - watchHabits() — весь справочник
/// - watchActiveSession() → watchSelectedHabitIds(sessionId) — привязки
///   текущей сессии, реактивно переключается при смене sessionId.
///
/// Перезапуск приложения больше не сбрасывает галки — оба стрима читают
/// напрямую из БД и эмитят актуальное значение сразу при подписке.
class HabitsNotifier extends ChangeNotifier {
  final HabitRepository _habitRepository;
  final SessionRepository _sessionRepository;
  final AddActionUseCase _addActionUseCase;
  final SyncService? _sync;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<Habit> _habits = [];
  List<Habit> get habits => _habits;

  List<String> _selectedHabitIds = [];
  List<String> get selectedHabitIds => _selectedHabitIds;

  String? _currentSessionId;
  String? get currentSessionId => _currentSessionId;

  int _sessionPhase = 0;

  void setSessionPhase(int phase) {
    _sessionPhase = phase;
  }

  StreamSubscription<List<Habit>>? _habitsSub;
  StreamSubscription? _sessionSub;
  StreamSubscription<List<String>>? _selectedIdsSub;

  HabitsNotifier({
    required HabitRepository habitRepository,
    required SessionRepository sessionRepository,
    required AddActionUseCase addActionUseCase,
    SyncService? sync,
  })  : _habitRepository = habitRepository,
        _sessionRepository = sessionRepository,
        _addActionUseCase = addActionUseCase,
        _sync = sync {
    _habitsSub = _habitRepository.watchHabits().listen((habits) {
      _habits = habits;
      _isLoading = false;
      notifyListeners();
    });

    // Слушаем сессию → при смене sessionId пересоздаём подписку на selectedIds
    _sessionSub = _sessionRepository.watchActiveSession().listen((session) {
      final newSessionId = session?.id;
      if (newSessionId == _currentSessionId) return;

      _currentSessionId = newSessionId;
      _selectedIdsSub?.cancel();

      if (newSessionId == null) {
        _selectedHabitIds = [];
        notifyListeners();
        return;
      }

      _selectedIdsSub = _habitRepository
          .watchSelectedHabitIds(newSessionId)
          .listen((ids) {
        _selectedHabitIds = ids;
        notifyListeners();
        _triggerWidgetUpdate();
      });
    });
  }

  void _triggerWidgetUpdate() {
    WidgetDataService.updateWidgetData(
      activeHabits:     _habits.where((h) => _selectedHabitIds.contains(h.id)).toList(),
      dayStatus:        'regular',
      hasActiveSession: _currentSessionId != null,
      balance:          0,
      dailyLimit:       0,
      sessionPhase:     _sessionPhase,
    ).catchError((_) {});
  }

  @override
  void dispose() {
    _habitsSub?.cancel();
    _sessionSub?.cancel();
    _selectedIdsSub?.cancel();
    super.dispose();
  }

  /// Оставлен для обратной совместимости с HabitManagementPage.
  /// sessionId обновляется через стрим — этот метод больше не нужен для загрузки.
  void loadHabits({String? currentSessionId}) {
    // no-op: данные приходят через watchHabits() и watchSelectedHabitIds()
    // sessionId уже отслеживается через watchActiveSession() в конструкторе
  }

  Future<void> toggleHabitSelection(String sessionId, String habitId) async {
    await _habitRepository.toggleHabitSelection(sessionId, habitId);
  }

  Future<void> addHabit(
    String title,
    int scoreValue,
    String emoji, {
    Set<String>? localSelectedIds,
    void Function(Set<String>)? onLocalSelectionChanged,
  }) async {
    final newHabit = Habit(
      id: '',
      title: title,
      emoji: emoji,
      scoreValue: scoreValue,
      sessionId: _currentSessionId,
    );
    final savedId = await _habitRepository.addHabitAndGetId(newHabit);
    if (savedId != null) {
      if (onLocalSelectionChanged != null && localSelectedIds != null) {
        onLocalSelectionChanged({...localSelectedIds, savedId});
      } else if (_currentSessionId != null) {
        await _habitRepository.toggleHabitSelection(_currentSessionId!, savedId);
      }
      _sync?.pushHabits().catchError((_) {});
      _sync?.pushSessionHabits().catchError((_) {});
    }
  }

  Future<void> updateHabit(Habit habit) async {
    await _habitRepository.updateHabit(habit);
    _sync?.pushHabits().catchError((_) {});
  }


  Future<void> archiveHabit(String habitId) async {
    await _habitRepository.archiveHabit(habitId);
    _sync?.pushHabits().catchError((_) {});
  }

  Future<void> reloadHabits() async {
    debugPrint('[reloadHabits] called, habits count before: ${_habits.length}');
    final habits = await _habitRepository.getHabits();
    debugPrint('[reloadHabits] loaded: ${habits.map((h) => h.title).toList()}');
    _habits = habits;
    notifyListeners();
  }

  Future<void> hitHabit(Habit habit, {dynamic scoringNotifier}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _addActionUseCase.execute(habit);

      if (scoringNotifier != null) {
        await scoringNotifier.refreshScore();
      }
    } catch (e) {
      debugPrint('Ошибка при вызове hitHabit: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addActionLog({
    required String habitId,
    required int points,
    required DateTime timestamp,
  }) async {
    try {
      final habit = _habits.firstWhere(
        (h) => h.id == habitId,
        orElse: () => Habit(id: habitId, title: habitId, emoji: '❓', scoreValue: points),
      );
      await _addActionUseCase.execute(habit);
    } catch (e) {
      debugPrint('Ошибка при записи действия в addActionLog: $e');
    }
  }
}