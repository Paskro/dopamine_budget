class Session {
  final String id;
  final DateTime createdAt;
  final int phase; // 0 = Калибровка, 1 = Контроль
  final double? avgScore; // Средний балл, вычисляется после калибровки
  final bool shouldDecrease; // Нужно ли снижать лимит каждую неделю
  final int? decreasePercentage; // На сколько процентов снижать (например, 20)
  final int? decreaseInterval; // Интервал в днях

  const Session({
    required this.id,
    required this.createdAt,
    required this.phase,
    this.avgScore,
    this.shouldDecrease = false,
    this.decreasePercentage,
    this.decreaseInterval,
  });

  /// Бизнес-логика: Вычисляем текущий дневной лимит дофамина
  /// Если фаза калибровки (0) или AVG еще не посчитан — лимита нет (возвращаем null)
  double? get dailyLimit {
    if (phase == 0 || avgScore == null) return null;

    if (shouldDecrease && decreasePercentage != null) {
      // Формула: LIMIT = AVG - %снижения
      // Например: 50 баллов - 20% = 40 баллов
      final reduction = avgScore! * (decreasePercentage! / 100);
      return avgScore! - reduction;
    }

    // Если снижение не включено, лимит равен среднему баллу калибровки
    return avgScore;
  }
}