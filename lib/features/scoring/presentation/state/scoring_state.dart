class ScoringState {
  final int score;

  ScoringState({required this.score});

  ScoringState copyWith({int? score}) {
    return ScoringState(
      score: score ?? this.score,
    );
  }
}