import '../entities/habit.dart';

abstract class HabitRepository {
  // === Legacy Future API ===

  Future<List<Habit>> getHabits();
  Future<void> saveHabit(Habit habit);
  Future<void> addHabit(Habit habit);
  Future<int?> addHabitAndGetId(Habit habit);
  Future<void> updateHabit(Habit habit);
  Future<void> deleteHabit(int habitId);
  Future<void> toggleHabitSelection(String sessionId, int habitId);
  Future<List<int>> getSelectedHabitIdsForSession(String sessionId);

  // ===========================================================================
  // STREAM API
  // ===========================================================================

  /// Весь справочник привычек. Обновляется при add/update/delete.
  Stream<List<Habit>> watchHabits();

  /// ID привычек привязанных к сессии. Обновляется при toggle.
  Stream<List<int>> watchSelectedHabitIds(String sessionId);
}