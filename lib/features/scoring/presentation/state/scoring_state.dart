import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';

class ScoringState {
  final double dailyLimit;
  final int pointsSpentToday;
  final int gamificationPoints;
  final bool isOverLimit;
  final bool isLoading;
  final String phase;
  final Map<String, int> habitClicksToday;
  final DateTime? lastUpdateDate;
  final String? currentSessionId;
  final Session? currentSession;
  final List<double>? historicalScores;
  final bool isShrinkingEnabled;
  final double? decreasePercentage;
  final String? decreaseInterval;

  const ScoringState({
    required this.dailyLimit,
    required this.pointsSpentToday,
    required this.gamificationPoints,
    required this.isOverLimit,
    required this.isLoading,
    required this.phase,
    required this.habitClicksToday,
    this.lastUpdateDate,
    this.currentSessionId,
    this.currentSession,
    this.historicalScores,
    this.isShrinkingEnabled = false,
    this.decreasePercentage,
    this.decreaseInterval,
  });

  factory ScoringState.initial() {
    return const ScoringState(
      dailyLimit: 0.0,
      pointsSpentToday: 0,
      gamificationPoints: 0,
      isOverLimit: false,
      isLoading: false,
      phase: 'control',
      habitClicksToday: {},
      isShrinkingEnabled: false,
    );
  }

  ScoringState copyWith({
    double? dailyLimit,
    int? pointsSpentToday,
    int? gamificationPoints,
    bool? isOverLimit,
    bool? isLoading,
    String? phase,
    Map<String, int>? habitClicksToday,
    DateTime? lastUpdateDate,
    String? currentSessionId,
    Session? currentSession,
    List<double>? historicalScores,
    bool? isShrinkingEnabled,
    double? decreasePercentage,
    String? decreaseInterval,
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
      currentSessionId: currentSessionId ?? this.currentSessionId,
      currentSession: currentSession ?? this.currentSession,
      historicalScores: historicalScores ?? this.historicalScores,
      isShrinkingEnabled: isShrinkingEnabled ?? this.isShrinkingEnabled,
      decreasePercentage: decreasePercentage ?? this.decreasePercentage,
      decreaseInterval: decreaseInterval ?? this.decreaseInterval,
    );
  }
}