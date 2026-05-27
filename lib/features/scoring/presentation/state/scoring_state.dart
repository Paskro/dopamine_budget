import 'package:flutter/foundation.dart';

@immutable
class ScoringState {
  final int dailyLimit;
  final int pointsSpentToday;
  final int gamificationPoints; // Наша копилка сэкономленных очков
  final bool isOverLimit;
  final Map<String, int> habitClicksToday; // Какая привычка сколько раз нажата сегодня

  const ScoringState({
    required this.dailyLimit,
    required this.pointsSpentToday,
    required this.gamificationPoints,
    required this.isOverLimit,
    required this.habitClicksToday,
  });

  // Начальное состояние (заглушка до загрузки данных)
  factory ScoringState.initial() {
    return const ScoringState(
      dailyLimit: 0,
      pointsSpentToday: 0,
      gamificationPoints: 0,
      isOverLimit: false,
      habitClicksToday: {},
    );
  }

  // Метод для удобного копирования состояния с измененными полями
  ScoringState copyWith({
    int? dailyLimit,
    int? pointsSpentToday,
    int? gamificationPoints,
    bool? isOverLimit,
    Map<String, int>? habitClicksToday,
  }) {
    return ScoringState(
      dailyLimit: dailyLimit ?? this.dailyLimit,
      pointsSpentToday: pointsSpentToday ?? this.pointsSpentToday,
      gamificationPoints: gamificationPoints ?? this.gamificationPoints,
      isOverLimit: isOverLimit ?? this.isOverLimit,
      habitClicksToday: habitClicksToday ?? this.habitClicksToday,
    );
  }
}