class Habit {
  final String id;
  final String title;
  final String emoji;
  final int scoreValue;
  final String? sessionId;

  const Habit({
    required this.id,
    required this.title,
    required this.emoji,
    required this.scoreValue,
    this.sessionId,
  });

  Habit copyWith({
    String? id,
    String? title,
    String? emoji,
    int? scoreValue,
    String? sessionId,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      scoreValue: scoreValue ?? this.scoreValue,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}
