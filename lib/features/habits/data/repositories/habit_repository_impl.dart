import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import 'package:dopamine_budget/features/habits/domain/entities/habit.dart';
import 'package:dopamine_budget/features/habits/domain/repositories/habit_repository.dart';

class HabitRepositoryImpl implements HabitRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  HabitRepositoryImpl(this._db);

  @override
  Future<List<Habit>> getHabits() async {
    final rows = await (
        _db.select(_db.habitsTable)
          ..where((t) => t.isArchived.equals(false))
    ).get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> addHabit(Habit habit) async {
    await addHabitAndGetId(habit);
  }

  @override
  Future<String?> addHabitAndGetId(Habit habit) async {
    try {
      final id = _uuid.v4();
      await _db.into(_db.habitsTable).insert(
        HabitsTableCompanion.insert(
          id: id,
          title: habit.title,
          scoreValue: habit.scoreValue,
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );
      return id;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    await (_db.update(_db.habitsTable)
      ..where((t) => t.id.equals(habit.id)))
        .write(HabitsTableCompanion(
      title: Value(habit.title),
      scoreValue: Value(habit.scoreValue),
      updatedAt: Value(DateTime.now().toIso8601String()),
    ));
  }

  @override
  Future<void> archiveHabit(String habitId) async {
    await _db.archiveHabit(habitId);
  }

  @override
  Future<void> toggleHabitSelection(String sessionId, String habitId) async {
    await _db.toggleHabitSelection(sessionId, habitId);
  }

  @override
  Future<List<String>> getSelectedHabitIdsForSession(String sessionId) async {
    return _db.getSelectedHabitIdsForSession(sessionId);
  }

  @override
  Stream<List<Habit>> watchHabits() {
    return _db.watchHabits().map(
          (rows) => rows.map(_fromRow).toList(),
    );
  }

  @override
  Stream<List<String>> watchSelectedHabitIds(String sessionId) {
    return _db.watchSelectedHabitIds(sessionId);
  }

  Habit _fromRow(HabitsTableData row) {
    return Habit(id: row.id, title: row.title, scoreValue: row.scoreValue);
  }
}