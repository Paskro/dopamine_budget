import 'package:flutter/material.dart';
import 'scoring_state.dart';

import 'package:dopamine_budget/core/utils/time_provider.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/features/scoring/domain/repositories/scoring_repository.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/verify_calibration_expiry_usecase.dart';
import 'package:dopamine_budget/features/scoring/domain/usecases/get_current_dopamine_balance_usecase.dart';

// lib/features/scoring/presentation/state/scoring_notifier.dart

class ScoringNotifier extends ValueNotifier<ScoringState> {
  final dynamic _calculateScoreUseCase;
  final SessionRepository _sessionRepository;
  final ScoringRepository _scoringRepository;
  final dynamic _getSessionsUseCase;
  final VerifyCalibrationExpiryUseCase _verifyCalibrationExpiry;
  final GetCurrentDopamineBalanceUseCase _getDopamineBalance;

  ScoringNotifier({
    required dynamic calculateScoreUseCase,
    required SessionRepository sessionRepository,
    required ScoringRepository scoringRepository,
    required dynamic getSessionsUseCase,
    required VerifyCalibrationExpiryUseCase verifyCalibrationExpiry,
    required GetCurrentDopamineBalanceUseCase getDopamineBalance,
  })  : _calculateScoreUseCase = calculateScoreUseCase,
        _sessionRepository = sessionRepository,
        _scoringRepository = scoringRepository,
        _getSessionsUseCase = getSessionsUseCase,
        _verifyCalibrationExpiry = verifyCalibrationExpiry,
        _getDopamineBalance = getDopamineBalance,
        super(ScoringState.initial()) {
    refreshTodayState();
  }

  // ==========================================
  // БЛОК 1: АВТОМАТИЧЕСКИЙ СБРОС ДНЯ (LAZY RESET)
  // ==========================================

  Future<void> checkAndResetDayIfNeeded() async {
    final now = TimeProvider.now;
    final todayDate = DateTime(now.year, now.month, now.day);

    print('Проверка смены дня... Текущая дата: $todayDate, Дата в стейте: ${state.lastUpdateDate}');

    if (state.lastUpdateDate == null || state.lastUpdateDate!.isBefore(todayDate)) {
      print('🚨 Фиксируем смену суток! Сбрасываем дневные счетчики.');

      final yesterdayDate = state.lastUpdateDate;
      if (yesterdayDate != null) {
        await _closeYesterdayIfNeeded(yesterdayDate);
      }

      state = state.copyWith(
        pointsSpentToday: 0,
        habitClicksToday: {},
        lastUpdateDate: todayDate,
      );

      await refreshTodayState();
    } else {
      await refreshTodayState();
    }
  }

  Future<void> _closeYesterdayIfNeeded(DateTime yesterday) async {
    try {
      final currentSession = state.currentSession;
      if (currentSession == null) return;

      await _sessionRepository.getOrCreateDayLog(
        date: yesterday,
        sessionId: currentSession.id,
      );

      print('✅ День $yesterday зафиксирован в DaysTable.');
    } catch (e) {
      print('⚠️ Не удалось закрыть день $yesterday: $e');
    }
  }

  // ==========================================
  // БЛОК 2: СИНХРОНИЗАЦИЯ СОСТОЯНИЯ С БД + АВТОФАЗЫ
  // ==========================================

  Future<void> refreshTodayState() async {
    try {
      // Проверка и переключение фазы делегированы Use Case
      await _verifyCalibrationExpiry.execute();

      final session = await _sessionRepository.getActiveSession();
      if (session == null) {
        print('Сессий пока нет, пропускаем расчет фаз и лимитов.');
        return;
      }

      // Баланс делегирован Use Case (включая обнуление при срыве)
      final balance = await _getDopamineBalance.execute();

      final int totalSpentToday =
          await _scoringRepository.getScoreForDay(TimeProvider.now);
      final Map<String, int> clicksToday =
          await _scoringRepository.getHabitClicksForDay(TimeProvider.now);

      final int currentLimit = (session.dailyLimit ?? 0).toInt();
      final String currentPhase = session.phase == 0 ? 'stats' : 'control';

      state = state.copyWith(
        dailyLimit: currentLimit,
        pointsSpentToday: totalSpentToday,
        gamificationPoints: 0,
        isOverLimit: balance <= 0 && totalSpentToday > 0,
        isLoading: false,
        phase: currentPhase,
        habitClicksToday: clicksToday,
        currentSession: session,
        currentSessionId: session.id,
      );

      print('Стейт обновлён. Баланс: $balance, Лимит: $currentLimit, Фаза: $currentPhase');
    } catch (e, stack) {
      print('Ошибка обновления состояния скоринга: $e');
      print(stack);
    }
  }

  // ==========================================
  // БЛОК 3: ОБРАБОТКА ПОЛЬЗОВАТЕЛЬСКИХ СОБЫТИЙ
  // ==========================================

  Future<void> refreshScore() async {
    await refreshTodayState();
  }

  Future<void> spendDopamine(String habitType, int scoreValue) async {
    try {
      await _scoringRepository.saveAction(
        habitType: habitType,
        scoreValue: scoreValue,
        timestamp: TimeProvider.now,
      );
      print('Действие "$habitType" записано.');
    } catch (e) {
      print('Ошибка при вызове saveAction: $e');
    }
    await refreshTodayState();
  }

  // ==========================================
  // БЛОК 4: УПРАВЛЕНИЕ ФАЗАМИ СЕССИИ (КОНТРОЛЬ)
  // ==========================================

  Future<void> applyDefaultControlSettings() async {
    final currentSession = state.currentSession;
    if (currentSession == null) return;

    try {
      await _sessionRepository.updateSessionToControl(
          sessionId: currentSession.id);
      await refreshTodayState();
    } catch (e) {
      print('Ошибка при активации быстрого старта: $e');
    }
  }

  // ==========================================
  // БЛОК 5: ВСПОМОГАТЕЛЬНЫЕ ГЕТТЕРЫ / СЕТТЕРЫ
  // ==========================================

  ScoringState get state => value;
  set state(ScoringState newState) => value = newState;

  String get currentSessionId => state.currentSessionId ?? '';

  Future<String?> getMostFrequentHabit(DateTime sessionStartDate) async {
    try {
      return await _sessionRepository.getMostFrequentHabitSince(sessionStartDate);
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, int>>> getHabitScoresPerDay(
      DateTime sessionStartDate, int calibrationDays) async {
    try {
      return await _sessionRepository.getScoresPerHabitPerDay(
          sessionStartDate, calibrationDays);
    } catch (_) {
      return [];
    }
  }
}