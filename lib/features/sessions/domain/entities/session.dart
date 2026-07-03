import 'package:dopamine_budget/core/utils/time_provider.dart';

class Session {
  final String id;
  final DateTime createdAt;
  final int phase;
  final double? avgScore;
  final bool isReviewed;
  final bool shouldDecrease;
  final int calibrationDays;
  final DateTime? controlStartedAt;

  // Shrinking Mode (ТЗ v3)
  final double? baseShrinkingLimit;
  final DateTime? shrinkingStartedAt;
  final double? decreasePercentage;
  final int? decreaseIntervalDays;
  final double? shrunkenLimit;

  const Session({
    required this.id,
    required this.createdAt,
    required this.phase,
    this.avgScore,
    this.isReviewed = false,
    this.shouldDecrease = false,
    this.calibrationDays = 3,
    this.controlStartedAt,
    this.baseShrinkingLimit,
    this.shrinkingStartedAt,
    this.decreasePercentage,
    this.decreaseIntervalDays,
    this.shrunkenLimit,
  });

  Session copyWith({
    String? id,
    DateTime? createdAt,
    int? phase,
    double? avgScore,
    bool? isReviewed,
    bool? shouldDecrease,
    int? calibrationDays,
    DateTime? controlStartedAt,
    double? baseShrinkingLimit,
    DateTime? shrinkingStartedAt,
    double? decreasePercentage,
    int? decreaseIntervalDays,
    double? shrunkenLimit,
  }) {
    return Session(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      phase: phase ?? this.phase,
      avgScore: avgScore ?? this.avgScore,
      isReviewed: isReviewed ?? this.isReviewed,
      shouldDecrease: shouldDecrease ?? this.shouldDecrease,
      calibrationDays: calibrationDays ?? this.calibrationDays,
      controlStartedAt: controlStartedAt ?? this.controlStartedAt,
      baseShrinkingLimit: baseShrinkingLimit ?? this.baseShrinkingLimit,
      shrinkingStartedAt: shrinkingStartedAt ?? this.shrinkingStartedAt,
      decreasePercentage: decreasePercentage ?? this.decreasePercentage,
      decreaseIntervalDays: decreaseIntervalDays ?? this.decreaseIntervalDays,
      shrunkenLimit: shrunkenLimit ?? this.shrunkenLimit,
    );
  }

  DateTime get balanceStartTime {
    if (controlStartedAt != null) return controlStartedAt!;
    final now = TimeProvider.now;
    return DateTime(now.year, now.month, now.day);
  }
}