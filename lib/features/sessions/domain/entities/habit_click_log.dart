class HabitClickLog {
  final String habitId;
  final String habitTitle;
  final int scoreCost;
  final DateTime timestamp;

  const HabitClickLog({
    required this.habitId,
    required this.habitTitle,
    required this.scoreCost,
    required this.timestamp,
  });
}