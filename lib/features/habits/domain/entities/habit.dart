class Habit {
  final String id;        // Уникальный номер привычки (например, '1', '2')
  final String title;     // Название (например, 'Сигареты')
  final int scoreValue;   // Сколько баллов забирает (например, 5 или 10)

  const Habit({
    required this.id,
    required this.title,
    required this.scoreValue,
  });

  // Удобный инструмент, чтобы быстро копировать и изменять привычку
  Habit copyWith({
    String? id,
    String? title,
    int? scoreValue,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      scoreValue: scoreValue ?? this.scoreValue,
    );
  }
}