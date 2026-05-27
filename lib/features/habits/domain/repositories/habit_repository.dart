import '../entities/habit.dart';

abstract class HabitRepository {
  Future<List<Habit>> getHabits();
  Future<void> addHabit(Habit habit);
  Future<void> updateHabit(Habit habit); // <-- Новый метод для редактирования
  Future<void> deleteHabit(String id);   // <-- Новый метод для удаления
}