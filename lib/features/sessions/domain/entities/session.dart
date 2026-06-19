import 'package:dopamine_budget/core/utils/time_provider.dart';

class Session {
  final String id;
  final DateTime createdAt;
  final int phase;
  final double? avgScore;
  final bool shouldDecrease;
  final int? decreasePercentage;
  final String? decreaseInterval;
  final bool isReviewed;
  final int calibrationDays;

  /// Момент перехода в фазу контроля. null пока в калибровке.
  final DateTime? controlStartedAt;
  final int? lastReviewedControlWeek;

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
    this.controlStartedAt,
    this.lastReviewedControlWeek,
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
    DateTime? controlStartedAt,
    int? lastReviewedControlWeek,
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
      controlStartedAt: controlStartedAt ?? this.controlStartedAt,
      lastReviewedControlWeek: lastReviewedControlWeek ?? this.lastReviewedControlWeek,
    );
  }

  double? get dailyLimit {
    if (phase == 0 || avgScore == null) return null;

    if (shouldDecrease && decreasePercentage != null) {
      final reduction = avgScore! * (decreasePercentage! / 100);
      return avgScore! - reduction;
    }

    return avgScore;
  }

  /// Начало отсчёта баланса в фазе контроля.
  /// Если controlStartedAt не записан — используем начало текущих суток
  /// как fallback (для сессий созданных до добавления этого поля).
  DateTime get balanceStartTime {
    if (controlStartedAt != null) return controlStartedAt!;
    final now = TimeProvider.now;
    return DateTime(now.year, now.month, now.day);
  }
}