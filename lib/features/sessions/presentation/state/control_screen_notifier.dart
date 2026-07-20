import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dopamine_budget/core/utils/time_provider.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/day_log.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/features/habits/domain/repositories/habit_repository.dart';
import 'package:dopamine_budget/features/habits/domain/entities/habit.dart';
import 'package:dopamine_budget/features/scoring/domain/usecases/get_daily_limit_usecase.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/habit_click_log.dart';

enum ControlScreenStatus { active, brokenLocked }

class ControlScreenState {
  final ControlScreenStatus status;
  final int balance;
  final int dailyLimit;
  final List<Habit> habits;
  final List<int> selectedIds;
  final bool isLoading;
  final List<HabitClickLog> todayLogs;

  /// 'regular' | 'ideal' | 'almost_ideal' | 'broken'
  final String dayStatus;

  /// true, если сегодня уже был хотя бы один клик по привычке
  /// (производная от потраченного баланса, см. ControlScreenNotifier._spentToday).
  final bool hasHabitClickToday;

  const ControlScreenState({
    required this.status,
    required this.balance,
    required this.dailyLimit,
    required this.habits,
    required this.selectedIds,
    required this.isLoading,
    required this.dayStatus,
    required this.hasHabitClickToday,
    required this.todayLogs,
  });

  factory ControlScreenState.initial() => const ControlScreenState(
    status: ControlScreenStatus.active,
    balance: 0,
    dailyLimit: 0,
    habits: [],
    selectedIds: [],
    isLoading: true,
    dayStatus: 'regular',
    hasHabitClickToday: false,
    todayLogs: [],
  );

  ControlScreenState copyWith({
    ControlScreenStatus? status,
    int? balance,
    int? dailyLimit,
    List<Habit>? habits,
    List<int>? selectedIds,
    bool? isLoading,
    String? dayStatus,
    bool? hasHabitClickToday,
    List<HabitClickLog>? todayLogs,
  }) {
    return ControlScreenState(
      status: status ?? this.status,
      balance: balance ?? this.balance,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      habits: habits ?? this.habits,
      selectedIds: selectedIds ?? this.selectedIds,
      isLoading: isLoading ?? this.isLoading,
      dayStatus: dayStatus ?? this.dayStatus,
      hasHabitClickToday: hasHabitClickToday ?? this.hasHabitClickToday,
      todayLogs: todayLogs ?? this.todayLogs,
    );
  }

  List<Habit> get sessionHabits => habits
      .where((h) => selectedIds.contains(int.tryParse(h.id)))
      .toList();

  /// Кнопка «Я сегодня молодец» показывается, если:
  /// 1. день ещё ничем не помечен (dayStatus == 'regular'),
  /// 2. сегодня не было ни одного клика по привычке,
  /// 3. текущее время >= 20:00 (TimeProvider.now, не системные часы).
  bool get canShowGoodBoyButton =>
      dayStatus == 'regular' &&
          !hasHabitClickToday &&
          TimeProvider.now.hour >= 20;
}

class ControlScreenNotifier extends ChangeNotifier {
  final SessionRepository _sessionRepository;
  final HabitRepository _habitRepository;
  final GetDailyLimitUseCase _getDailyLimitUseCase;

  ControlScreenState _state = ControlScreenState.initial();
  ControlScreenState get state => _state;

  // One-shot события для UI (SnackBar и т.п.) — отдельно от _state,
  // чтобы сообщение не "всплывало" повторно при каждом ребилде виджета,
  // подписанного на ChangeNotifier.
  final StreamController<String> _errorEventsController =
  StreamController<String>.broadcast();
  Stream<String> get errorEvents => _errorEventsController.stream;

  Session? _session;
  DayLog? _dayLog;
  List<Habit> _habits = [];
  List<int> _selectedIds = [];
  int _spentToday = 0;
  List<HabitClickLog> _todayLogs = [];

  StreamSubscription<Session?>? _sessionSub;
  StreamSubscription<DayLog?>? _dayLogSub;
  StreamSubscription<List<Habit>>? _habitsSub;
  StreamSubscription<List<int>>? _selectedIdsSub;
  StreamSubscription<int>? _spentSub;
  StreamSubscription<List<HabitClickLog>>? _logsSub;

  String? _currentSessionId;
  DateTime? _currentDay;

  ControlScreenNotifier({
    required SessionRepository sessionRepository,
    required HabitRepository habitRepository,
    required GetDailyLimitUseCase getDailyLimitUseCase,
  })  : _sessionRepository = sessionRepository,
        _habitRepository = habitRepository,
        _getDailyLimitUseCase = getDailyLimitUseCase {
    _habitsSub = _habitRepository.watchHabits().listen((habits) {
      _habits = habits;
      _recompute();
    });

    _sessionSub = _sessionRepository.watchActiveSession().listen((session) {
      debugPrint('[ControlScreen] watchActiveSession emit: phase=${session?.phase}, avgScore=${session?.avgScore}');
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
    _logsSub?.cancel();
    _spentSub?.cancel();

    _dayLogSub = _sessionRepository.watchDayLog(today).listen((dayLog) {
      _dayLog = dayLog;
      _recompute();
    });

    _logsSub = _sessionRepository.watchHabitLogsForDay(today).listen((logs) {
      _todayLogs = logs;
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

  bool _isRecomputing = false;
  bool _recomputeQueued = false;

  Future<void> _recompute() async {
    if (_isRecomputing) {
      _recomputeQueued = true;
      return;
    }
    _isRecomputing = true;

    try {
      final session = _session;
      if (session == null) return;

      final String dayStatus = _dayLog?.dayStatus ?? 'regular';
      final bool isBroken = dayStatus == 'broken';

      final double? currentLimit = await _getDailyLimitUseCase.execute();
      if (currentLimit == null) return;

      final int dailyLimit = currentLimit.round();
      final int balance = isBroken
          ? 0
          : (dailyLimit - _spentToday).clamp(0, dailyLimit);

      debugPrint('[ControlScreen] _recompute: phase=${session.phase}, dailyLimit=$dailyLimit, spent=$_spentToday, balance=$balance, dayStatus=$dayStatus');

      _state = _state.copyWith(
        status: isBroken ? ControlScreenStatus.brokenLocked : ControlScreenStatus.active,
        balance: balance,
        dailyLimit: dailyLimit,
        habits: _habits,
        selectedIds: _selectedIds,
        isLoading: false,
        dayStatus: dayStatus,
        hasHabitClickToday: _spentToday > 0,
        todayLogs: _todayLogs,
      );
      notifyListeners();
    } finally {
      _isRecomputing = false;
      if (_recomputeQueued) {
        _recomputeQueued = false;
        await _recompute();
      }
    }
  }

  @override
  void dispose() {
    _sessionSub?.cancel();
    _dayLogSub?.cancel();
    _habitsSub?.cancel();
    _selectedIdsSub?.cancel();
    _spentSub?.cancel();
    _errorEventsController.close();
    super.dispose();
    _logsSub?.cancel();
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
      _errorEventsController.add('Не удалось зафиксировать срыв. Попробуйте ещё раз.');
    }
  }

  Future<void> confirmGoodBoy() async {
    final session = _session;
    if (session == null) return;
    final today = DateTime(TimeProvider.now.year, TimeProvider.now.month, TimeProvider.now.day);
    try {
      await _sessionRepository.getOrCreateDayLog(date: today, sessionId: session.id);
      await _sessionRepository.markDayAsGoodBoy(today);
    } on StateError catch (e) {
      debugPrint('[ControlScreen] confirmGoodBoy отклонён: $e');
      _errorEventsController.add('День уже зафиксирован как срыв — отметка недоступна.');
    } catch (e) {
      debugPrint('[ControlScreen] Ошибка confirmGoodBoy: $e');
      _errorEventsController.add('Не удалось сохранить отметку. Попробуйте ещё раз.');
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
    } on StateError catch (e) {
      debugPrint('[ControlScreen] logHabitClick отклонён: $e');
      _errorEventsController.add('День уже зафиксирован как срыв — клики недоступны.');
    } catch (e) {
      debugPrint('[ControlScreen] Ошибка logHabitClick: $e');
      _errorEventsController.add('Не удалось записать действие. Попробуйте ещё раз.');
    }
  }
}