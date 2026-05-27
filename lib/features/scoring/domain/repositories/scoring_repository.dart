abstract class ScoringRepository {
  /// Сохранить новое действие в лог
  Future<void> saveAction({
    required String habitType,
    required int scoreValue,
    required DateTime timestamp,
  });

  /// Получить общую сумму баллов за конкретный день
  Future<int> getScoreForDay(DateTime date);

  /// Получить мапу "Привычка -> Количество кликов" за конкретный день
  Future<Map<String, int>> getHabitClicksForDay(DateTime date);
}