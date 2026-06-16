import 'package:drift/drift.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import 'package:dopamine_budget/features/habits/domain/entities/habit.dart';
import 'package:dopamine_budget/features/habits/domain/repositories/habit_repository.dart';

class HabitRepositoryImpl implements HabitRepository {
  final AppDatabase _db;

  HabitRepositoryImpl(this._db);

  @override
  Future<List<Habit>> getHabits() async {
    final rows = await _db.select(_db.habitsTable).get();
    return rows.map(_habitFromRow).toList();
  }

  @override
  Future<void> saveHabit(Habit habit) async {
    final isNew = habit.id.isEmpty || habit.id == '0' || habit.id.length > 10;

    final companion = HabitsTableCompanion(
      id: isNew ? const Value.absent() : Value(int.parse(habit.id)),
      title: Value(habit.title),
      scoreValue: Value(habit.scoreValue),
    );

    await _db.into(_db.habitsTable).insertOnConflictUpdate(companion);
  }

  @override
  Future<void> addHabit(Habit habit) async {
    await saveHabit(habit);
  }

  @override
  Future<int?> addHabitAndGetId(Habit habit) async {
    try {
      final companion = HabitsTableCompanion(
        id: const Value.absent(),
        title: Value(habit.title),
        scoreValue: Value(habit.scoreValue),
      );
      final id = await _db.into(_db.habitsTable).insert(companion);
      return id;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    await saveHabit(habit);
  }

  @override
  Future<void> deleteHabit(int habitId) async {
    await _db.transaction(() async {
      await (_db.delete(_db.habitsTable)
            ..where((t) => t.id.equals(habitId)))
          .go();
      await (_db.delete(_db.sessionHabitsTable)
            ..where((t) => t.habitId.equals(habitId)))
          .go();
    });
  }

  @override
  Future<void> toggleHabitSelection(String sessionId, int habitId) async {
    await _db.transaction(() async {
      final query = _db.select(_db.sessionHabitsTable)
        ..where((t) =>
            t.sessionId.equals(sessionId) & t.habitId.equals(habitId));
      final existing = await query.getSingleOrNull();

      if (existing != null) {
        await (_db.delete(_db.sessionHabitsTable)
              ..where((t) => t.id.equals(existing.id)))
            .go();
      } else {
        await _db.into(_db.sessionHabitsTable).insert(
          SessionHabitsTableCompanion.insert(
            sessionId: sessionId,
            habitId: habitId,
          ),
        );
      }
    });
  }

  @override
  Future<List<int>> getSelectedHabitIdsForSession(String sessionId) async {
    final query = _db.select(_db.sessionHabitsTable)
      ..where((t) => t.sessionId.equals(sessionId));
    final rows = await query.get();
    return rows.map<int>((row) => row.habitId).toList();
  }

  // =========================================================================
  // STREAM API
  // =========================================================================

  @override
  Stream<List<Habit>> watchHabits() {
    return _db.watchHabits().map(
          (rows) => rows.map(_habitFromRow).toList(),
        );
  }

  @override
  Stream<List<int>> watchSelectedHabitIds(String sessionId) {
    return _db.watchSelectedHabitIds(sessionId);
  }

  // =========================================================================
  // PRIVATE HELPERS
  // =========================================================================

  Habit _habitFromRow(HabitsTableData row) {
    return Habit(
      id: row.id.toString(),
      title: row.title,
      scoreValue: row.scoreValue,
    );
  }
}