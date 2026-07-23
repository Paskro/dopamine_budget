import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';

abstract class ScoringRepository {
  /// Сохранить новое действие в лог
  Future<void> saveAction({
    required String habitType,
    required int scoreValue,
    required DateTime timestamp,
  });

  /// Получить общую сумму баллов за конкретный день
  Future<int> getScoreForDay(DateTime date);

  /// Получить сумму потраченных дофаминовых баллов за конкретную дату
  Future<int> getSpentScoreByDay(DateTime date);

  /// Получить мапу "Привычка -> Количество кликов" за конкретный день
  Future<Map<String, int>> getHabitClicksForDay(DateTime date);

  /// возвращаем количество реальных дней с записями
  Future<List<DateTime>> getUniqueRecordedDays({required String sessionId});

  /// Получить текущую активную сессию пользователя
  Future<Session?> getActiveSession();

  /// Получить суммарную стоимость деструктивных действий за конкретные сутки
  Future<int> getTotalScoreCostForDate(DateTime date);

  /// Обновляет фазу сессии на Контроль и фиксирует прочтение итогов
  Future<void> updateSessionToControl({required String sessionId});

  /// Агрегация трат по привычкам за 7 дней [weekStart, weekStart+7)
  Future<List<({String habitId, String habitName, int totalPts})>> getWeeklyHabitTotals({
    required DateTime weekStart,
  });
}