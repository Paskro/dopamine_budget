class HabitLimitExceededException implements Exception {
  const HabitLimitExceededException();

  @override
  String toString() => 'Максимум 6 привычек в бесплатной версии';
}
