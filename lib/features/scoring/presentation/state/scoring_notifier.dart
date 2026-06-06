import 'package:flutter/material.dart';
import 'scoring_state.dart';

import 'package:dopamine_budget/core/utils/time_provider.dart';

class ScoringNotifier extends ValueNotifier<ScoringState> {
  final dynamic _calculateScoreUseCase;
  final dynamic _sessionRepository;
  final dynamic _getSessionsUseCase; // <-- 1. Добавили поле для юзкейса сессий

  ScoringNotifier({
    required dynamic calculateScoreUseCase,
    required dynamic sessionRepository,
    required dynamic getSessionsUseCase, // <-- 2. Добавили в конструктор
  })  : _calculateScoreUseCase = calculateScoreUseCase,
        _sessionRepository = sessionRepository,
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
      // Подтягиваем сессии через переданный UseCase или репозиторий
      final sessions = await _sessionRepository.getAllSessions();

      if (sessions.isEmpty) {
        print('Сессий пока нет, пропускаем расчет фаз и лимитов.');
        return;
      }

      var currentSession = sessions.first;

      // --------------------------------------------------
      // МАГИЯ АВТОМАТИЧЕСКОГО ПЕРЕКЛЮЧЕНИЯ ФАЗ СТАРТ
      // --------------------------------------------------
      // Вызываем наш обновленный UseCase с кортежем (Record) на выходе
      final (isPhaseChanged, updatedSession) =
          await _calculateScoreUseCase.checkAndProcessCalibration(currentSession);

      if (isPhaseChanged) {
        print('🚀 Калибровка завершена! Переключаем фазу на control.');
        // Сохраняем обновленную сессию (с посчитанными avg и limit) в базу данных
        await _sessionRepository.updateSession(updatedSession);
        // Переприсваиваем локальную переменную, чтобы UI сразу взял новые цифры
        currentSession = updatedSession;
      }
      // --------------------------------------------------
      // МАГИЯ АВТОМАТИЧЕСКОГО ПЕРЕКЛЮЧЕНИЯ ФАЗ КОНЕЦ

      // Получаем лимит строго из активной сессии
      int currentLimit = (currentSession.dailyLimit ?? 100).toInt();

      // Если мы все еще в фазе статистики, лимита быть не должно (или он равен дефолту)
      if (currentSession.phase == 'stats' || currentSession.phase == 0) {
        currentLimit = (currentSession.avgScore ?? 100).toInt();
      }

      final dynamic rawClicks = await _calculateScoreUseCase.getTodayHabitClicks(TimeProvider.now);

      final Map<String, int> clicksToday = {};
      if (rawClicks != null) {
        final Map<dynamic, dynamic> safeMap = rawClicks as Map<dynamic, dynamic>;
        for (final entry in safeMap.entries) {
          final String keyString = entry.key.toString();
          final int valueInt = (entry.value as num).toInt();
          clicksToday[keyString] = valueInt;
        }
      }

      final int totalSpentToday = await _calculateScoreUseCase.getScoreForDay(TimeProvider.now);

      String currentPhase = 'control';
      final rawPhase = currentSession.phase;
      if (rawPhase is int) {
        currentPhase = rawPhase == 0 ? 'stats' : 'control';
      } else {
        currentPhase = rawPhase.toString();
      }

      // Собираем исторические баллы для графика калибровки
      List<double> historicalScores = [];
      try {
        historicalScores = await _sessionRepository.getScoresPerDaySince(currentSession.createdAt);
      } catch (_) {
        // Граф недоступен — не блокируем основной поток
      }

      state = state.copyWith(
        dailyLimit: currentLimit,
        pointsSpentToday: totalSpentToday,
        gamificationPoints: 0,
        isOverLimit: totalSpentToday > currentLimit,
        isLoading: false,
        phase: currentPhase,
        habitClicksToday: clicksToday,
        currentSession: currentSession,
        currentSessionId: currentSession.id?.toString(),
        historicalScores: historicalScores,
      );

      print('Стейт успешно обновлен! Потрачено: $totalSpentToday, Лимит: $currentLimit, Фаза: $currentPhase');
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
      await _calculateScoreUseCase.registerAction(
        habitType: habitType,
        scoreValue: scoreValue,
        timestamp: TimeProvider.now,
      );
      print('Действие "$habitType" успешно записано в виртуальный день!');
    } catch (e) {
      print('Ошибка при вызове registerAction: $e');
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
}