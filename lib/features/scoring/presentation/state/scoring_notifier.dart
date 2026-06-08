import 'package:flutter/material.dart';
import 'scoring_state.dart';

import 'package:dopamine_budget/core/utils/time_provider.dart';

class ScoringNotifier extends ValueNotifier<ScoringState> {
  final dynamic _calculateScoreUseCase;
  final dynamic _sessionRepository;
  final dynamic _scoringRepository;
  final dynamic _getSessionsUseCase;

  ScoringNotifier({
    required dynamic calculateScoreUseCase,
    required dynamic sessionRepository,
    required dynamic scoringRepository,
    required dynamic getSessionsUseCase,
  })  : _calculateScoreUseCase = calculateScoreUseCase,
        _sessionRepository = sessionRepository,
        _scoringRepository = scoringRepository,
        _getSessionsUseCase = getSessionsUseCase,
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

  // ==========================================
  // БЛОК 2: СИНХРОНИЗАЦИЯ СОСТОЯНИЯ С БД + АВТОФАЗЫ
  // ==========================================

  Future<void> refreshTodayState() async {
    try {
      final sessions = await _sessionRepository.getAllSessions();

      if (sessions.isEmpty) {
        print('Сессий пока нет, пропускаем расчет фаз и лимитов.');
        return;
      }

      var currentSession = sessions.first;

      // --------------------------------------------------
      // АВТОМАТИЧЕСКОЕ ПЕРЕКЛЮЧЕНИЕ ФАЗ
      // Если сессия в фазе калибровки (phase == 0) — проверяем
      // набрала ли она нужное количество дней с записями.
      // --------------------------------------------------
      if (currentSession.phase == 0) {
        final uniqueDays = await _scoringRepository.getUniqueRecordedDays();
        final completedDays = uniqueDays.length;
        final targetDays = currentSession.calibrationDays;

        final today = DateTime(TimeProvider.now.year, TimeProvider.now.month, TimeProvider.now.day);
        final lastCalibrationDay = uniqueDays.isNotEmpty
            ? DateTime(uniqueDays.last.year, uniqueDays.last.month, uniqueDays.last.day)
            : null;
        final lastDayIsComplete = lastCalibrationDay != null && lastCalibrationDay.isBefore(today);

        if (completedDays >= targetDays && lastDayIsComplete) {
          // Считаем средний балл за дни калибровки
          double totalScore = 0;
          for (final day in uniqueDays.take(targetDays)) {
            totalScore += await _scoringRepository.getScoreForDay(day);
          }
          final avgScore = totalScore / targetDays;

          // Обновляем сессию в БД — переводим в фазу контроля
          final updatedSession = currentSession.copyWith(
            phase: 1,
            avgScore: avgScore,
          );
          await _sessionRepository.updateSession(updatedSession);
          currentSession = updatedSession;
          print('🚀 Калибровка завершена! avg=$avgScore, переключаем на control.');
        }
      }

      // Лимит берём из сессии
      int currentLimit = (currentSession.dailyLimit ?? 100).toInt();
      if (currentSession.phase == 0) {
        currentLimit = (currentSession.avgScore ?? 0).toInt();
      }

      // Баллы и клики за сегодня
      final int totalSpentToday = await _scoringRepository.getScoreForDay(TimeProvider.now);
      final Map<String, int> clicksToday =
          await _scoringRepository.getHabitClicksForDay(TimeProvider.now);

      final String currentPhase = currentSession.phase == 0 ? 'stats' : 'control';

      state = state.copyWith(
        dailyLimit: currentLimit,
        pointsSpentToday: totalSpentToday,
        gamificationPoints: 0,
        isOverLimit: totalSpentToday > currentLimit,
        isLoading: false,
        phase: currentPhase,
        habitClicksToday: clicksToday,
        currentSession: currentSession,
        currentSessionId: currentSession.id,
      );

      print('Стейт обновлён. Потрачено: $totalSpentToday, Лимит: $currentLimit, Фаза: $currentPhase');
    } catch (e, stack) {
      print('Ошибка обновления состояния скоринга: $e');
      print(stack);
    }
  }

  // ==========================================
  // БЛОК 3: ОБРАБОТКА ПОЛЬЗОВАТЕЛЬСКИХ СОБЫТИЙ
  // ==========================================

  /// Явный перерасчет баланса очков «на лету» — вызывается из HabitsNotifier
  /// сразу после фиксации срыва, чтобы HomePage обновился мгновенно
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

    /// Логика кнопки «Быстрый старт» на экране итогов калибровки.
    /// Переводит текущую сессию в фазу Контроля и фиксирует ознакомление.
    Future<void> applyDefaultControlSettings() async {
      final currentSession = state.currentSession;
      if (currentSession == null) return;

      try {
        // 1. Вызываем метод репозитория для обновления только phase и isReviewed в БД.
        // Имя метода должно совпадать с тем, что вы напишете в вашем sessionRepository.
        await _sessionRepository.updateSessionToControl(sessionId: currentSession.id);

        // 2. Обязательно перечитываем состояние из БД, чтобы сбросить UI стейт.
        // Метод refreshTodayState подтянет обновленную сессию, и экран итогов закроется.
        await refreshTodayState();
      } catch (e) {
        // Здесь можно добавить логирование ошибок или прокинуть ошибку дальше в UI
        print('Ошибка при активации быстрого старта: $e');
      }
    }

  // ==========================================
  // БЛОК 5: ВСПОМОГАТЕЛЬНЫЕ ГЕТТЕРЫ / СЕТТЕРЫ
  // ==========================================
  ScoringState get state => value;
  set state(ScoringState newState) => value = newState;

  // Текущий ID сессии — берётся из стейта, нужен для передачи в HabitManagementPage
  String get currentSessionId => state.currentSessionId ?? '';

  /// Топ-1 привычка по количеству срабатываний за период калибровки
  Future<String?> getMostFrequentHabit(DateTime sessionStartDate) async {
    try {
      return await _sessionRepository.getMostFrequentHabitSince(sessionStartDate);
    } catch (_) {
      return null;
    }
  }

  /// Баллы по привычкам за каждый день калибровки — для цветного графика
  Future<List<Map<String, int>>> getHabitScoresPerDay(DateTime sessionStartDate, int calibrationDays) async {
    try {
      return await _sessionRepository.getScoresPerHabitPerDay(sessionStartDate, calibrationDays);
    } catch (_) {
      return [];
    }
  }
}