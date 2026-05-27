class Session {
  final String id;
  final DateTime createdAt;
  final int phase; // 0 = stats (калибровка), 1 = control (контроль)
  final double? avgScore; // Базовый лимит XP

  // Новые поля для гибкого контроля усыхания лимита
  final bool shouldDecrease;
  final double? decreasePercentage;
  final String? decreaseInterval; // 'week' или 'month'

  Session({
    required this.id,
    required this.createdAt,
    required this.phase,
    this.avgScore,
    required this.shouldDecrease,
    this.decreasePercentage,
    this.decreaseInterval,
  });

  // Удобные геттеры для проверки фазы в коде
  bool get isStatsPhase => phase == 0;
  bool get isControlPhase => phase == 1;

  // Метод для расчета даты окончания фазы статистики.
  // Теперь мы можем передавать сюда любое количество дней (3, 7 или сколько введет пользователь).
  // По умолчанию ставим 7 дней.
  DateTime getStatsEndDate({int durationDays = 7}) {
    return createdAt.add(Duration(days: durationDays));
  }

  // Проверяем, завершилась ли фаза калибровки (принимает длительность калибровки)
  bool isStatsTimedOut({int durationDays = 7}) {
    if (!isStatsPhase) return false;
    return DateTime.now().isAfter(getStatsEndDate(durationDays: durationDays));
  }
}