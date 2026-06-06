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
  Future<List<DateTime>> getUniqueRecordedDays();

  /// Получить текущую активную сессию пользователя
    Future<Session?> getActiveSession();

    /// Получить суммарную стоимость деструктивных действий за конкретные сутки
    Future<int> getTotalScoreCostForDate(DateTime date);
}