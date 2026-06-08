class Session {
  final String id;
  final DateTime createdAt;
  final int phase; // 0 = Калибровка, 1 = Контроль
  final double? avgScore; // Средний балл, вычисляется после калибровки
  final bool shouldDecrease;
  final int? decreasePercentage;
  final String? decreaseInterval; // Интервал снижения: 'week' или 'month'
  final bool isReviewed;
  final int calibrationDays; // Количество дней калибровки

  const Session({
    required this.id,
    required this.createdAt,
    required this.phase,
    this.avgScore,
    this.shouldDecrease = false,
    this.decreasePercentage,
    this.decreaseInterval,
    this.isReviewed = false,
    this.calibrationDays = 3,
  });

Session copyWith({
    String? id,
    DateTime? createdAt,
    int? phase,
    double? avgScore,
    bool? shouldDecrease,
    int? decreasePercentage,
    String? decreaseInterval,
    bool? isReviewed,
    int? calibrationDays,
  }) {
    return Session(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      phase: phase ?? this.phase,
      avgScore: avgScore ?? this.avgScore,
      shouldDecrease: shouldDecrease ?? this.shouldDecrease,
      decreasePercentage: decreasePercentage ?? this.decreasePercentage,
      decreaseInterval: decreaseInterval ?? this.decreaseInterval,
      isReviewed: isReviewed ?? this.isReviewed,
      calibrationDays: calibrationDays ?? this.calibrationDays,
    );
  }

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