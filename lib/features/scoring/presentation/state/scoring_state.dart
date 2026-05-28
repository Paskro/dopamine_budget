import 'package:flutter/foundation.dart';

class ScoringState {
  final int dailyLimit;
  final int pointsSpentToday;
  final int gamificationPoints;
  final bool isOverLimit;
  final bool isLoading;
  final String phase;
  final Map<String, int> habitClicksToday;
  final DateTime? lastUpdateDate; // Наше новое поле для фиксации дней

  const ScoringState({
    required this.dailyLimit,
    required this.pointsSpentToday,
    required this.gamificationPoints,
    required this.isOverLimit,
    required this.isLoading,
    required this.phase,
    required this.habitClicksToday,
    this.lastUpdateDate,
  });

  // Возвращаем factory на место, чтобы super(ScoringState.initial()) завелся
  factory ScoringState.initial() {
    return const ScoringState(
      dailyLimit: 0,
      pointsSpentToday: 0,
      gamificationPoints: 0,
      isOverLimit: false,
      isLoading: false,
      phase: 'control',
      habitClicksToday: {},
      lastUpdateDate: null,
    );
  }

  ScoringState copyWith({
    int? dailyLimit,
    int? pointsSpentToday,
    int? gamificationPoints,
    bool? isOverLimit,
    bool? isLoading,
    String? phase,
    Map<String, int>? habitClicksToday,
    DateTime? lastUpdateDate,
  }) {
    return ScoringState(
      dailyLimit: dailyLimit ?? this.dailyLimit,
      pointsSpentToday: pointsSpentToday ?? this.pointsSpentToday,
      gamificationPoints: gamificationPoints ?? this.gamificationPoints,
      isOverLimit: isOverLimit ?? this.isOverLimit,
      isLoading: isLoading ?? this.isLoading,
      phase: phase ?? this.phase,
      habitClicksToday: habitClicksToday ?? this.habitClicksToday,
      lastUpdateDate: lastUpdateDate ?? this.lastUpdateDate,
    );
  }
}