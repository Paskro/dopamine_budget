import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:dopamine_budget/features/habits/data/tables/habits_table.dart';
import 'package:dopamine_budget/features/sessions/data/tables/sessions_table.dart';

part 'app_database.g.dart';

class ActionsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get habitType => text()();
  IntColumn get scoreValue => integer()();
  DateTimeColumn get timestamp => dateTime()();
}

@DriftDatabase(tables: [
  ActionsTable,
  HabitsTable,
  SessionsTable,
  SessionHabitsTable
])
class AppDatabase extends _$AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();

  AppDatabase._internal() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(sessionHabitsTable);
        }
      },
    );
  }

  // Возвращает список ID привычек, выбранных для данной сессии
  Future<List<int>> getSelectedHabitIdsForSession(String sessionId) async {
    final query = select(sessionHabitsTable)
      ..where((t) => t.sessionId.equals(sessionId));
    final rows = await query.get();
    return rows.map((row) => row.habitId).toList();
  }

  // Переключает привычку в сессии: если есть — удаляет, если нет — добавляет
  Future<void> toggleHabitSelection(String sessionId, int habitId) async {
    final query = select(sessionHabitsTable)
      ..where((t) => t.sessionId.equals(sessionId) & t.habitId.equals(habitId));
    final existing = await query.getSingleOrNull();

    if (existing != null) {
      await (delete(sessionHabitsTable)..where((t) => t.id.equals(existing.id))).go();
    } else {
      await into(sessionHabitsTable).insert(
        SessionHabitsTableCompanion.insert(
          sessionId: sessionId,
          habitId: habitId,
        ),
      );
    }
  }

  // Удаляет привычку из глобального справочника и все её связи с сессиями
  Future<void> deleteHabit(int habitId) async {
    await (delete(sessionHabitsTable)..where((t) => t.habitId.equals(habitId))).go();
    await (delete(habitsTable)..where((t) => t.id.equals(habitId))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}