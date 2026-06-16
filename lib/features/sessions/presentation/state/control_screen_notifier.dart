// control_screen_notifier.dart — ПОЛНАЯ ЗАМЕНА ФАЙЛА

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dopamine_budget/core/utils/time_provider.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/day_log.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/features/habits/domain/repositories/habit_repository.dart';
import 'package:dopamine_budget/features/habits/domain/entities/habit.dart';

enum ControlScreenStatus { active, brokenLocked }

class ControlScreenState {
  final ControlScreenStatus status;
  final int balance;
  final int dailyLimit;
  final List<Habit> habits;
  final List<int> selectedIds;
  final bool isLoading;

  const ControlScreenState({
    required this.status,
    required this.balance,
    required this.dailyLimit,
    required this.habits,
    required this.selectedIds,
    required this.isLoading,
  });

  factory ControlScreenState.initial() => const ControlScreenState(
    status: ControlScreenStatus.active,
    balance: 0,
    dailyLimit: 0,
    habits: [],
    selectedIds: [],
    isLoading: true,
  );

  ControlScreenState copyWith({
    ControlScreenStatus? status,
    int? balance,
    int? dailyLimit,
    List<Habit>? habits,
    List<int>? selectedIds,
    bool? isLoading,
  }) {
    return ControlScreenState(
      status: status ?? this.status,
      balance: balance ?? this.balance,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      habits: habits ?? this.habits,
      selectedIds: selectedIds ?? this.selectedIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  List<Habit> get sessionHabits => habits
      .where((h) => selectedIds.contains(int.tryParse(h.id)))
      .toList();
}

class ControlScreenNotifier extends ChangeNotifier {
  final SessionRepository _sessionRepository;
  final HabitRepository _habitRepository;

  ControlScreenState _state = ControlScreenState.initial();
  ControlScreenState get state => _state;

  Session? _session;
  DayLog? _dayLog;
  List<Habit> _habits = [];
  List<int> _selectedIds = [];
  int _spentToday = 0;

  StreamSubscription<Session?>? _sessionSub;
  StreamSubscription<DayLog?>? _dayLogSub;
  StreamSubscription<List<Habit>>? _habitsSub;
  StreamSubscription<List<int>>? _selectedIdsSub;
  StreamSubscription<int>? _spentSub;

  String? _currentSessionId;
  DateTime? _currentDay;

  ControlScreenNotifier({
    required SessionRepository sessionRepository,
    required HabitRepository habitRepository,
  })  : _sessionRepository = sessionRepository,
        _habitRepository = habitRepository {
    _habitsSub = _habitRepository.watchHabits().listen((habits) {
      _habits = habits;
      _recompute();
    });

    _sessionSub = _sessionRepository.watchActiveSession().listen((session) {
      debugPrint('[ControlScreen] watchActiveSession emit: phase=${session?.phase}, avgScore=${session?.avgScore}, dailyLimit=${session?.dailyLimit}');
      _session = session;
      _subscribeToScore();

      final newSessionId = session?.id;
      if (newSessionId != _currentSessionId) {
        _currentSessionId = newSessionId;
        _selectedIdsSub?.cancel();

        if (newSessionId != null) {
          _selectedIdsSub = _habitRepository
              .watchSelectedHabitIds(newSessionId)
              .listen((ids) {
            _selectedIds = ids;
            _recompute();
          });
        } else {
          _selectedIds = [];
        }
      }

      _recompute();
    });

    _subscribeToToday();
  }

  void _subscribeToToday() {
    final now = TimeProvider.now;
    final today = DateTime(now.year, now.month, now.day);
    _currentDay = today;

    _dayLogSub?.cancel();
    _spentSub?.cancel();

    _dayLogSub = _sessionRepository.watchDayLog(today).listen((dayLog) {
      debugPrint('[ControlScreen] watchDayLog emit: date=$today, isBroken=${dayLog?.isBrokenClicked}, dayLog=$dayLog');
      _dayLog = dayLog;
      _recompute();
    });

    _subscribeToScore();
  }

  void _subscribeToScore() {
    _spentSub?.cancel();
    final now = TimeProvider.now;
    final today = DateTime(now.year, now.month, now.day);
    final endOfDay = today.add(const Duration(days: 1));

    // balanceStartTime нужен только в первые сутки контроля — чтобы отсечь
    // калибровочные клики того же дня. На каждый последующий день окно
    // должно начинаться с начала текущих суток, иначе spent накапливается
    // за весь срок контроля вместо посуточного сброса.
    final sessionStart = _session?.balanceStartTime;
    final start = (sessionStart != null && sessionStart.isAfter(today))
        ? sessionStart
        : today;

    _spentSub = _sessionRepository.watchScoreForDay(start, endOfDay).listen((spent) {
      debugPrint('[ControlScreen] watchScoreForDay emit: spent=$spent, start=$start');
      _spentToday = spent;
      _recompute();
    });
  }

  void checkForNewDay() {
    final now = TimeProvider.now;
    final today = DateTime(now.year, now.month, now.day);
    if (_currentDay == null || _currentDay!.isBefore(today)) {
      _subscribeToToday();
    }
  }

  /// Псевдоним для control_screen.dart
  void checkAndResetDayIfNeeded() => checkForNewDay();

  void _recompute() {
    final bool isBroken = _dayLog?.isBrokenClicked ?? false;
    final int dailyLimit = (_session?.dailyLimit ?? 0).toInt();
    final int balance = isBroken
        ? 0
        : (dailyLimit - _spentToday).clamp(0, dailyLimit > 0 ? dailyLimit : 0);

    debugPrint('[ControlScreen] _recompute: phase=${_session?.phase}, dailyLimit=$dailyLimit, spent=$_spentToday, balance=$balance, broken=$isBroken');

    _state = _state.copyWith(
      status: isBroken ? ControlScreenStatus.brokenLocked : ControlScreenStatus.active,
      balance: balance,
      dailyLimit: dailyLimit,
      habits: _habits,
      selectedIds: _selectedIds,
      isLoading: false,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _sessionSub?.cancel();
    _dayLogSub?.cancel();
    _habitsSub?.cancel();
    _selectedIdsSub?.cancel();
    _spentSub?.cancel();
    super.dispose();
  }

  Future<void> confirmBreak() async {
    final session = _session;
    if (session == null) return;
    final today = DateTime(TimeProvider.now.year, TimeProvider.now.month, TimeProvider.now.day);
    try {
      await _sessionRepository.getOrCreateDayLog(date: today, sessionId: session.id);
      await _sessionRepository.markDayAsBroken(today);
    } catch (e) {
      debugPrint('[ControlScreen] Ошибка confirmBreak: $e');
    }
  }

  Future<void> confirmGoodBoy() async {
    final session = _session;
    if (session == null) return;
    final today = DateTime(TimeProvider.now.year, TimeProvider.now.month, TimeProvider.now.day);
    try {
      await _sessionRepository.getOrCreateDayLog(date: today, sessionId: session.id);
      await _sessionRepository.markDayAsGoodBoy(today);
    } catch (e) {
      debugPrint('[ControlScreen] Ошибка confirmGoodBoy: $e');
    }
  }

  /// Принимает habitId (как ожидает control_screen.dart) и зовёт
  /// существующий метод репозитория logHabitClickWithStatusCheck —
  /// он уже обновляет ActionsTable + DaysTable.dayStatus в одной транзакции.
  Future<void> logHabitClick({
    required String habitId,
    required int scoreCost,
  }) async {
    try {
      await _sessionRepository.logHabitClickWithStatusCheck(
        habitId: habitId,
        scoreCost: scoreCost,
        timestamp: TimeProvider.now,
      );
    } catch (e) {
      debugPrint('[ControlScreen] Ошибка logHabitClick: $e');
    }
  }
}