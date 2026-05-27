import 'package:flutter/material.dart';
import 'scoring_state.dart';

class ScoringNotifier extends ValueNotifier<ScoringState> {
  final dynamic _calculateScoreUseCase;
  final dynamic _sessionRepository;

  ScoringNotifier({
    required dynamic calculateScoreUseCase,
    required dynamic sessionRepository,
  })  : _calculateScoreUseCase = calculateScoreUseCase,
        _sessionRepository = sessionRepository,
        super(ScoringState.initial()) {
    refreshTodayState();
  }

  // ==========================================
  // БЛОК 1: АВТОМАТИЧЕСКИЙ СБРОС ДНЯ (LAZY RESET)
  // ==========================================

  /// Проверка смены календарного дня при входе в приложение
  Future<void> checkAndResetDayIfNeeded() async {
    final sessions = await _sessionRepository.getAllSessions();
    if (sessions.isEmpty) return;
    final session = sessions.first;

    final DateTime now = DateTime.now();
    final DateTime lastOpened = session.createdAt;

    final bool isNewDay = DateTime(now.year, now.month, now.day).isAfter(
      DateTime(lastOpened.year, lastOpened.month, lastOpened.day),
    );

    if (isNewDay) {
      // Здесь в будущем будет чистая бизнес-логика переноса очков в геймификацию
    }

    await refreshTodayState();
  }

  // ==========================================
  // БЛОК 2: СИНХРОНИЗАЦИЯ СОСТОЯНИЯ С БД
  // ==========================================

  /// Подтягивание актуальных данных за текущие сутки через UseCase
  Future<void> refreshTodayState() async {
    try {
      final sessions = await _sessionRepository.getAllSessions();

      // Получаем лимит строго из активной сессии
      int currentLimit = 0;
      if (sessions.isNotEmpty) {
        final session = sessions.first;
        // Защита от null: если это фаза ручного контроля и avgScore не задан,
        // в будущем заменим на корректное поле лимита контроля (например, manualLimit)
        currentLimit = (session.avgScore ?? 100).toInt();
      }

      // Запрашиваем данные у UseCase без обходных путей
      final Map<String, int> clicksToday = await _calculateScoreUseCase.getTodayHabitClicks();
      final int totalSpentToday = await _calculateScoreUseCase.getScoreForDay(DateTime.now());

      // Эмит нового чистого состояния в UI
      state = state.copyWith(
        dailyLimit: currentLimit,
        pointsSpentToday: totalSpentToday,
        gamificationPoints: 0,
        isOverLimit: totalSpentToday > currentLimit,
        habitClicksToday: clicksToday,
      );

      print('Стейт успешно обновлен! Потрачено: $totalSpentToday, Лимит: $currentLimit');
    } catch (e, stack) {
      print('Ошибка обновления состояния скоринга: $e');
      print(stack);
    }
  }

  // ==========================================
  // БЛОК 3: ОБРАБОТКА ПОЛЬЗОВАТЕЛЬСКИХ СОБЫТИЙ
  // ==========================================

  /// Обработка клика по привычке
  Future<void> spendDopamine(String habitType, int scoreValue) async {
    try {
      await _calculateScoreUseCase.registerAction(
        habitType: habitType,
        scoreValue: scoreValue,
      );
      print('Действие "$habitType" успешно записано!');
    } catch (e) {
      print('Ошибка при вызове registerAction: $e');
    }

    // Реактивно обновляем состояние экрана после транзакции
    await refreshTodayState();
  }

  // ==========================================
  // БЛОК 4: ВСПОМОГАТЕЛЬНЫЕ ГЕТТЕРЫ / СЕТТЕРЫ
  // ==========================================
  ScoringState get state => value;
  set state(ScoringState newState) => value = newState;
}