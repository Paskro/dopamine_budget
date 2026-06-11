import 'package:flutter/material.dart';
import 'package:dopamine_budget/core/utils/time_provider.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/features/scoring/domain/usecases/get_current_dopamine_balance_usecase.dart';
import 'package:dopamine_budget/features/habits/domain/repositories/habit_repository.dart';
import 'package:dopamine_budget/features/habits/domain/entities/habit.dart';

// lib/features/sessions/presentation/state/control_screen_notifier.dart

enum ControlScreenStatus { active, brokenLocked }

class ControlScreenState {
  final ControlScreenStatus status;
  final int balance;
  final int dailyLimit;
  final List<Habit> habits;      // привычки сессии — загружаются нотификатором
  final List<int> selectedIds;   // ID привязанных к сессии привычек
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

  /// Только привязанные к сессии привычки
  List<Habit> get sessionHabits => habits
      .where((h) => selectedIds.contains(int.tryParse(h.id)))
      .toList();
}

class ControlScreenNotifier extends ChangeNotifier {
  final SessionRepository _sessionRepository;
  final GetCurrentDopamineBalanceUseCase _getDopamineBalance;
  final HabitRepository _habitRepository;

  ControlScreenState _state = ControlScreenState.initial();
  ControlScreenState get state => _state;

  ControlScreenNotifier({
    required SessionRepository sessionRepository,
    required GetCurrentDopamineBalanceUseCase getDopamineBalance,
    required HabitRepository habitRepository,
  })  : _sessionRepository = sessionRepository,
        _getDopamineBalance = getDopamineBalance,
        _habitRepository = habitRepository {
    refresh();
  }

  Future<void> refresh() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final today = DateTime(
        TimeProvider.now.year,
        TimeProvider.now.month,
        TimeProvider.now.day,
      );

      final dayLog = await _sessionRepository.getDayLog(today);
      final session = await _sessionRepository.getActiveSession();

      final bool isBroken = dayLog?.isBrokenClicked ?? false;
      final int dailyLimit = (session?.dailyLimit ?? 0).toInt();
      final int balance = await _getDopamineBalance.execute();

      // Грузим все привычки и ID привязанных к сессии
      final allHabits = await _habitRepository.getHabits();
      final selectedIds = session != null
          ? await _habitRepository.getSelectedHabitIdsForSession(session.id)
          : <int>[];

      _state = _state.copyWith(
        status: isBroken
            ? ControlScreenStatus.brokenLocked
            : ControlScreenStatus.active,
        balance: balance,
        dailyLimit: dailyLimit,
        habits: allHabits,
        selectedIds: selectedIds,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('[ControlScreen] Ошибка refresh: $e');
      _state = _state.copyWith(isLoading: false);
    }

    notifyListeners();
  }

  Future<void> confirmBreak() async {
    final today = DateTime(
      TimeProvider.now.year,
      TimeProvider.now.month,
      TimeProvider.now.day,
    );

    final session = await _sessionRepository.getActiveSession();
    if (session == null) return;

    try {
      await _sessionRepository.getOrCreateDayLog(
        date: today,
        sessionId: session.id,
      );
      await _sessionRepository.markDayAsBroken(today);

      _state = _state.copyWith(
        status: ControlScreenStatus.brokenLocked,
        balance: 0,
        isLoading: false,
      );
      notifyListeners();
      debugPrint('[ControlScreen] Срыв зафиксирован.');
    } catch (e) {
      debugPrint('[ControlScreen] Ошибка confirmBreak: $e');
    }
  }

  Future<void> confirmGoodBoy() async {
    final today = DateTime(
      TimeProvider.now.year,
      TimeProvider.now.month,
      TimeProvider.now.day,
    );

    final session = await _sessionRepository.getActiveSession();
    if (session == null) return;

    try {
      await _sessionRepository.getOrCreateDayLog(
        date: today,
        sessionId: session.id,
      );
      await _sessionRepository.markDayAsGoodBoy(today);
      debugPrint('[ControlScreen] Статус дня → ideal.');
    } catch (e) {
      debugPrint('[ControlScreen] Ошибка confirmGoodBoy: $e');
    }
  }

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

      final int balance = await _getDopamineBalance.execute();
      _state = _state.copyWith(balance: balance);
      notifyListeners();
    } catch (e) {
      debugPrint('[ControlScreen] Ошибка logHabitClick: $e');
    }
  }
}