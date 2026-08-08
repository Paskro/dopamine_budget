import '../entities/habit.dart';

abstract class HabitRepository {
  Future<List<Habit>> getHabits();
  Future<void> addHabit(Habit habit);
  Future<String?> addHabitAndGetId(Habit habit);
  Future<void> updateHabit(Habit habit);
  Future<void> archiveHabit(String habitId);
  Future<void> toggleHabitSelection(String sessionId, String habitId);
  Future<List<String>> getSelectedHabitIdsForSession(String sessionId);
  Stream<List<Habit>> watchHabits();
  Stream<List<String>> watchSelectedHabitIds(String sessionId);
}