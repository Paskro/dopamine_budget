import 'package:flutter/foundation.dart';

@immutable
class StreakRecord {
  final String lastActiveDate;
  final double currentMultiplier;
  final double previousMultiplier;
  final bool isViewed;
  final bool hadActivityYesterday;

  const StreakRecord({
    required this.lastActiveDate,
    required this.currentMultiplier,
    required this.previousMultiplier,
    required this.isViewed,
    required this.hadActivityYesterday,
  });

  StreakRecord copyWith({
    String? lastActiveDate,
    double? currentMultiplier,
    double? previousMultiplier,
    bool? isViewed,
    bool? hadActivityYesterday,
  }) => StreakRecord(
    lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    currentMultiplier: currentMultiplier ?? this.currentMultiplier,
    previousMultiplier: previousMultiplier ?? this.previousMultiplier,
    isViewed: isViewed ?? this.isViewed,
    hadActivityYesterday: hadActivityYesterday ?? this.hadActivityYesterday,
  );
}