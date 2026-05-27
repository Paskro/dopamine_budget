class ScoreEntity {
  final double totalPoints;
  final DateTime date;
  final Map<String, int> habitCounts; // Название привычки -> количество

  ScoreEntity({
    required this.totalPoints,
    required this.date,
    required this.habitCounts,
  });
}