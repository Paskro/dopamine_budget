import 'dart:async';
import 'package:flutter/material.dart';
import 'scoring_state.dart';
import 'package:dopamine_budget/core/utils/time_provider.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/shrinking_period.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/features/scoring/domain/repositories/scoring_repository.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/verify_calibration_expiry_usecase.dart';
import 'package:dopamine_budget/features/scoring/domain/usecases/get_current_dopamine_balance_usecase.dart';
import 'package:dopamine_budget/features/scoring/domain/usecases/toggle_shrinking_mode_usecase.dart';
import 'package:dopamine_budget/features/scoring/domain/usecases/get_daily_limit_usecase.dart';

class ScoringNotifier extends ChangeNotifier {
  final SessionRepository _sessionRepository;
  final ScoringRepository _scoringRepository;
  final VerifyCalibrationExpiryUseCase _verifyCalibrationExpiry;
  final GetCurrentDopamineBalanceUseCase _getDopamineBalance;
  final GetDailyLimitUseCase _getDailyLimitUseCase;
  final ToggleShrinkingModeUseCase _toggleShrinkingMode;

  ScoringState _state = ScoringState.initial();
  ScoringState get state => _state;

  Session? _session;
  DateTime? _currentDay;
  int _spentToday = 0;
  bool _isRecomputing = false;
  int _executionCounter = 0;
  bool _recomputeQueued = false;

  StreamSubscription<Session?>? _sessionSub;
  StreamSubscription<int>? _spentSub;

  ScoringNotifier({
    required SessionRepository sessionRepository,
    required ScoringRepository scoringRepository,
    required VerifyCalibrationExpiryUseCase verifyCalibrationExpiry,
    required GetCurrentDopamineBalanceUseCase getDopamineBalance,
    required ToggleShrinkingModeUseCase toggleShrinkingMode,
    required GetDailyLimitUseCase getDailyLimitUseCase,
  })  : _sessionRepository = sessionRepository,
        _scoringRepository = scoringRepository,
        _verifyCalibrationExpiry = verifyCalibrationExpiry,
        _getDopamineBalance = getDopamineBalance,
        _toggleShrinkingMode = toggleShrinkingMode,
        _getDailyLimitUseCase = getDailyLimitUseCase {
    _sessionSub = _sessionRepository.watchActiveSession().listen((session) {
      debugPrint('[ScoringNotifier] watchActiveSession: phase=${session?.phase}');
      _session = session;
      _verifyCalibrationAndSync();
    });
  }

  // БЛОК 1: СМЕНА СУТОК

  Future<void> checkAndResetDayIfNeeded() async {
    final now = TimeProvider.now;
    final todayDate = DateTime(now.year, now.month, now.day);
    if (_currentDay == null || _currentDay!.isBefore(todayDate)) {
      debugPrint('[ScoringNotifier] Смена суток');
      final yesterdayDate = _currentDay;
      _currentDay = todayDate;
      if (yesterdayDate != null) await _closeYesterdayIfNeeded(yesterdayDate);
      _state = _state.copyWith(pointsSpentToday: 0, habitClicksToday: {}, lastUpdateDate: todayDate);
      notifyListeners();
      _verifyCalibrationAndSync();
    } else {
      _recompute();
    }
  }

  Future<void> _closeYesterdayIfNeeded(DateTime yesterday) async {
    if (_session == null) return;
    try {
      await _sessionRepository.getOrCreateDayLog(date: yesterday, sessionId: _session!.id);
    } catch (e) {
      debugPrint('[ScoringNotifier] Не удалось закрыть день $yesterday: $e');
    }
  }

  void _verifyCalibrationAndSync() async {
    try {
      await _verifyCalibrationExpiry.execute();
      _subscribeToScore();
    } catch (e) {
      debugPrint('[ScoringNotifier] Ошибка проверки калибровки: $e');
    }
  }

  // БЛОК 2: STREAM-ПОДПИСКА

  void _subscribeToScore() {
    _spentSub?.cancel();
    final now = TimeProvider.now;
    final today = DateTime(now.year, now.month, now.day);
    _currentDay = today;
    final start = _session?.controlStartedAt != null
        ? (_session!.controlStartedAt!.isAfter(today) ? today : _session!.controlStartedAt!)
        : today;
    _spentSub = _sessionRepository
        .watchScoreForDay(start, today.add(const Duration(days: 1)))
        .listen((spent) {
      final actualToday = DateTime(
        TimeProvider.now.year,
        TimeProvider.now.month,
        TimeProvider.now.day,
      );
      if (_currentDay != null && _currentDay!.isBefore(actualToday)) {
        _subscribeToScore();
        return;
      }
      _spentToday = spent;
      _recompute();
    });
  }

  // БЛОК 3: РАСЧЁТ СТЕЙТА

  Future<void> _recompute() async {
    final currentExecutionId = ++_executionCounter;
    if (_isRecomputing) {
      _recomputeQueued = true;
      return;
    }
    _isRecomputing = true;

    try {
      final session = _session;
      if (session == null) {
        if (currentExecutionId == _executionCounter) {
          _state = _state.copyWith(isLoading: false);
          notifyListeners();
        }
        return;
      }

      final balance = await _getDopamineBalance.execute();
      final clicksToday = await _scoringRepository.getHabitClicksForDay(TimeProvider.now);
      final currentLimit = await _getDailyLimitUseCase.execute() ?? 0.0;
      final activePeriod = await _sessionRepository.getActiveShrinkingPeriod(session.id);
      final isShrinkEditAllowed = activePeriod != null
          ? await _checkIsFirstDayOfNewPeriod(activePeriod)
          : false;

      if (currentExecutionId != _executionCounter) return;

      _state = _state.copyWith(
        dailyLimit: currentLimit,
        pointsSpentToday: _spentToday,
        gamificationPoints: 0,
        isOverLimit: balance <= 0 && _spentToday > 0,
        isLoading: false,
        phase: session.phase == 0 ? 'stats' : 'control',
        habitClicksToday: clicksToday,
        currentSession: session,
        currentSessionId: session.id,
        lastUpdateDate: _currentDay,
        isShrinkingEnabled: activePeriod != null,
        isShrinkEditAllowed: isShrinkEditAllowed,
        decreasePercentage: activePeriod != null
            ? (activePeriod.decreasePct * 100).roundToDouble()
            : _state.decreasePercentage,
        decreaseInterval: activePeriod != null
            ? (activePeriod.intervalDays == 7 ? 'week' : 'month')
            : _state.decreaseInterval,
      );

      notifyListeners();
      debugPrint('[ScoringNotifier] Лимит: $currentLimit, editAllowed: $isShrinkEditAllowed');
    } catch (e, stack) {
      debugPrint('[ScoringNotifier] Ошибка: $e\n$stack');
    } finally {
      _isRecomputing = false;
      if (_recomputeQueued) {
        _recomputeQueued = false;
        _recompute();
      }
    }
  }

  Future<bool> _checkIsFirstDayOfNewPeriod(ShrinkingPeriod period) async {
    final today = DateTime(TimeProvider.now.year, TimeProvider.now.month, TimeProvider.now.day);
    final startDay = DateTime(period.startedAt.year, period.startedAt.month, period.startedAt.day);
    final daysPassed = today.difference(startDay).inDays;
    if (daysPassed <= 0 || daysPassed % period.intervalDays != 0) return false;
    final isReviewed = await _sessionRepository.isShrinkingReportReviewed(
      period.sessionId,
      today.subtract(Duration(days: daysPassed % period.intervalDays == 0
          ? 0
          : period.intervalDays)),
    );
    return !isReviewed;
  }

  // БЛОК 4: МУТАЦИИ

  Future<void> refreshTodayState() async => _recompute();
  Future<void> refreshScore() async => _recompute();

  Future<void> spendDopamine(String habitType, int scoreValue) async {
    try {
      await _scoringRepository.saveAction(
        habitType: habitType,
        scoreValue: scoreValue,
        timestamp: TimeProvider.now,
      );
    } catch (e) {
      debugPrint('[ScoringNotifier] spendDopamine error: $e');
    }
  }

  Future<void> applyDefaultControlSettings() async {
    if (_session == null) return;
    try {
      await _sessionRepository.updateSessionToControl(sessionId: _session!.id);
    } catch (e) {
      debugPrint('[ScoringNotifier] applyDefaultControlSettings error: $e');
    }
  }

  @override
  String get currentSessionId => _state.currentSessionId ?? '';

  Future<String?> getMostFrequentHabit(DateTime sessionStartDate) async {
    try {
      return await _sessionRepository.getMostFrequentHabitSince(sessionStartDate);
    } catch (_) {
      return null;
    }
  }

  Future<void> toggleShrinking(bool isEnabled, {double? pct, String? interval}) async {
    if (_session == null) return;
    try {
      final decreasePct = pct ?? (_state.decreasePercentage ?? 2.0);
      final intervalStr = interval ?? (_state.decreaseInterval ?? 'week');
      await _toggleShrinkingMode.execute(
        isEnabled: isEnabled,
        decreasePct: isEnabled ? decreasePct / 100.0 : null,
        intervalDays: isEnabled ? (intervalStr == 'week' ? 7 : 30) : null,
      );
      await _recompute();
    } catch (e) {
      debugPrint('[ScoringNotifier] toggleShrinking error: $e');
    }
  }

  Future<void> updateDecreaseSettings({
    required double percentage,
    required String interval,
  }) async {
    _state = _state.copyWith(decreasePercentage: percentage, decreaseInterval: interval);
    notifyListeners();
  }

  Future<List<Map<String, int>>> getHabitScoresPerDay(
      DateTime sessionStartDate, int calibrationDays) async {
    try {
      final session = _session;
      if (session == null) return [];
      final uniqueDays = await _scoringRepository.getUniqueRecordedDays(
        sessionId: session.id,
      );
      final daysToShow = uniqueDays
          .where((d) => d.isBefore(DateTime(
          TimeProvider.now.year,
          TimeProvider.now.month,
          TimeProvider.now.day)))
          .take(calibrationDays)
          .toList();
      return Future.wait(
        daysToShow.map((day) => _sessionRepository.getScoresPerHabitPerDay(day, 1)
            .then((list) => list.isNotEmpty ? list.first : <String, int>{})),
      );
    } catch (e) {
      debugPrint('[ScoringNotifier] getHabitScoresPerDay error: $e');
      return [];
    }
  }

  @override
  void dispose() {
    _sessionSub?.cancel();
    _spentSub?.cancel();
    super.dispose();
  }
}