import '../entities/habit.dart';

abstract class HabitRepository {
  Future<List<Habit>> getHabits();
  Future<void> saveHabit(Habit habit);
  Future<void> addHabit(Habit habit);
  Future<void> updateHabit(Habit habit);
  Future<void> deleteHabit(int habitId);
  Future<void> toggleHabitSelection(String sessionId, int habitId);
  Future<List<int>> getSelectedHabitIdsForSession(String sessionId);
}