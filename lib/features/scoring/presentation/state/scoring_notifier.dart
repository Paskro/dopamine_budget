import 'dart:async';
import 'package:flutter/material.dart';
import 'scoring_state.dart';

import 'package:dopamine_budget/core/utils/time_provider.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/features/scoring/domain/repositories/scoring_repository.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/verify_calibration_expiry_usecase.dart';
import 'package:dopamine_budget/features/scoring/domain/usecases/get_current_dopamine_balance_usecase.dart';
import 'package:dopamine_budget/features/scoring/domain/usecases/toggle_shrinking_mode_usecase.dart';
import 'package:dopamine_budget/features/scoring/domain/usecases/get_daily_limit_usecase.dart';

// lib/features/scoring/presentation/state/scoring_notifier.dart

class ScoringNotifier extends ChangeNotifier {
  final SessionRepository _sessionRepository;
  final ScoringRepository _scoringRepository;
  final VerifyCalibrationExpiryUseCase _verifyCalibrationExpiry;
  final GetCurrentDopamineBalanceUseCase _getDopamineBalance;
  final GetDailyLimitUseCase _getDailyLimitUseCase;

  ScoringState _state = ScoringState.initial();
  ScoringState get state => _state;

  Session? _session;
  DateTime? _currentDay;
  int _spentToday = 0;
  bool _isRecomputing = false;

  StreamSubscription<Session?>? _sessionSub;
  StreamSubscription<int>? _spentSub;

  final ToggleShrinkingModeUseCase _toggleShrinkingMode;

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
      debugPrint('[ScoringNotifier] watchActiveSession emit: phase=${session?.phase}');
      _session = session;
      _verifyCalibrationAndSync();
    });
  }
  // ==========================================
  // БЛОК 1: УПРАВЛЕНИЕ СМЕНОЙ СУТОК (РЕАКТИВНОЕ ПЕРЕПОДКЛЮЧЕНИЕ)
  // ==========================================

  /// Вызывается из UI перед рендерингом страниц или при нажатии кнопки "+1 День"
  Future<void> checkAndResetDayIfNeeded() async {
    final now = TimeProvider.now;
    final todayDate = DateTime(now.year, now.month, now.day);

    if (_currentDay == null || _currentDay!.isBefore(todayDate)) {
      debugPrint('[ScoringNotifier] 🚨 Фиксируем смену суток! Переподключаем стримы.');

      final yesterdayDate = _currentDay;
      _currentDay = todayDate;

      if (yesterdayDate != null) {
        await _closeYesterdayIfNeeded(yesterdayDate);
      }

      // Сбрасываем локальные счетчики в стейте перед перерасчетом
      _state = _state.copyWith(
        pointsSpentToday: 0,
        habitClicksToday: {},
        lastUpdateDate: todayDate,
      );
      notifyListeners();

      _verifyCalibrationAndSync();
    } else {
      _recompute();
    }
  }

  Future<void> _closeYesterdayIfNeeded(DateTime yesterday) async {
    try {
      if (_session == null) return;
      await _sessionRepository.getOrCreateDayLog(
        date: yesterday,
        sessionId: _session!.id,
      );
      debugPrint('[ScoringNotifier] ✅ День $yesterday зафиксирован в DaysTable.');
    } catch (e) {
      debugPrint('[ScoringNotifier] ⚠️ Не удалось закрыть день $yesterday: $e');
    }
  }

  void _verifyCalibrationAndSync() async {
    try {
      // Выполняем юзкейс проверки завершения калибровки
      await _verifyCalibrationExpiry.execute();

      // Переподписываемся на баланс под новые временные границы
      _subscribeToScore();
    } catch (e) {
      debugPrint('[ScoringNotifier] Ошибка при проверке калибровки: $e');
    }
  }

  // ==========================================
  // БЛОК 2: STREAM-ПОДПИСКА НА БАЛАНС ДНЯ
  // ==========================================

  void _subscribeToScore() {
    _spentSub?.cancel();

    final now = TimeProvider.now;
    final today = DateTime(now.year, now.month, now.day);
    _currentDay = today;
    final endOfDay = today.add(const Duration(days: 1));

    // Точка отсчета баланса берется из сессии (бизнес-правило из Паспорта)
    final start = _session?.balanceStartTime ?? today;

    _spentSub = _sessionRepository.watchScoreForDay(start, endOfDay).listen((spent) {
      debugPrint('[ScoringNotifier] watchScoreForDay emit: spent=$spent');
      _spentToday = spent;
      _recompute();
    });
  }

  // ==========================================
  // БЛОК 3: СИНХРОНИЗАЦИЯ И РАСЧЕТ СТЕЙТА (ЗАЩИТА ОТ RACE CONDITIONS)
  // ==========================================

  int _executionCounter = 0;
  bool _recomputeQueued = false;

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

      if (currentExecutionId != _executionCounter) return;

      final String currentPhase = session.phase == 0 ? 'stats' : 'control';

      _state = _state.copyWith(
        dailyLimit: currentLimit,
        pointsSpentToday: _spentToday,
        gamificationPoints: 0,
        isOverLimit: balance <= 0 && _spentToday > 0,
        isLoading: false,
        phase: currentPhase,
        habitClicksToday: clicksToday,
        currentSession: session,
        currentSessionId: session.id,
        lastUpdateDate: _currentDay,
        isShrinkingEnabled: session.shrinkingStartedAt != null,
        decreasePercentage: session.decreasePercentage != null
            ? (session.decreasePercentage! * 100).roundToDouble()
            : _state.decreasePercentage,
        decreaseInterval: session.decreaseIntervalDays != null
            ? (session.decreaseIntervalDays == 7 ? 'week' : 'month')
            : _state.decreaseInterval,
      );

      notifyListeners();
      debugPrint('[ScoringNotifier] Стейт успешно пересчитан. Фаза: $currentPhase, Лимит: $currentLimit');
    } catch (e, stack) {
      debugPrint('[ScoringNotifier] Ошибка обновления состояния скоринга: $e');
      debugPrint('$stack');
    } finally {
      _isRecomputing = false;
      if (_recomputeQueued) {
        _recomputeQueued = false;
        _recompute();
      }
    }
  }
  // ==========================================
  // БЛОК 4: МУТАЦИИ И ВНЕШНИЙ ИНТЕРФЕЙС
  // ==========================================

  Future<void> refreshTodayState() async {
    await _recompute();
  }

  Future<void> refreshScore() async {
    await _recompute();
  }

  Future<void> spendDopamine(String habitType, int scoreValue) async {
    try {
      await _scoringRepository.saveAction(
        habitType: habitType,
        scoreValue: scoreValue,
        timestamp: TimeProvider.now,
      );
      debugPrint('Действие "$habitType" успешно записано.');
    } catch (e) {
      debugPrint('Ошибка при вызове saveAction: $e');
    }
  }

  Future<void> applyDefaultControlSettings() async {
    if (_session == null) return;
    try {
      await _sessionRepository.updateSessionToControl(sessionId: _session!.id);
    } catch (e) {
      debugPrint('Ошибка при активации быстрого старта: $e');
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

  Future<void> toggleShrinking(bool isEnabled) async {
    if (isEnabled && _session != null) {
      final percentage = _state.decreasePercentage ?? 2.0;
      final interval = _state.decreaseInterval ?? 'week';
      await _sessionRepository.updateSession(
        _session!.copyWith(
          shrinkingStartedAt: isEnabled ? TimeProvider.now : null,
          baseShrinkingLimit: _session!.avgScore,
          decreasePercentage: percentage / 100.0,
          decreaseIntervalDays: interval == 'week' ? 7 : 30,
        ),
      );
    } else if (!isEnabled && _session != null) {
      await _sessionRepository.updateSession(
        _session!.copyWith(
          shrinkingStartedAt: null,
          baseShrinkingLimit: null,
          decreasePercentage: null,
          decreaseIntervalDays: null,
        ),
      );
    }
    _state = _state.copyWith(isShrinkingEnabled: isEnabled);
    notifyListeners();
    await _recompute();
  }

  Future<void> updateDecreaseSettings({
    required double percentage,
    required String interval,
  }) async {
    _state = _state.copyWith(
      decreasePercentage: percentage,
      decreaseInterval: interval,
    );
    notifyListeners();

    if (_state.isShrinkingEnabled && _session != null) {
      await _sessionRepository.updateSession(
        _session!.copyWith(
          decreasePercentage: percentage / 100.0,
          decreaseIntervalDays: interval == 'week' ? 7 : 30,
        ),
      );
    }
  }

  Future<List<Map<String, int>>> getHabitScoresPerDay(
      DateTime sessionStartDate, int calibrationDays) async {
    try {
      // Репозиторий сам принимает дату начала и количество дней калибровки,
      // и уже возвращает List<Map<String, int>>, который ждет CalibrationResultPage.
      return await _sessionRepository.getScoresPerHabitPerDay(
          sessionStartDate, calibrationDays);
    } catch (e) {
      debugPrint('[ScoringNotifier] Ошибка в getHabitScoresPerDay: $e');
      return [];
    }
  }
  void dispose() {
    _sessionSub?.cancel();
    _spentSub?.cancel();
    super.dispose();
  }
}