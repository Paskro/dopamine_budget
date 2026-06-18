import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:dopamine_budget/features/habits/data/tables/habits_table.dart';
import 'package:dopamine_budget/features/actions/data/tables/habit_logs_table.dart';
import 'package:dopamine_budget/features/sessions/data/tables/sessions_table.dart';
import 'package:dopamine_budget/features/sessions/data/tables/days_table.dart';

part 'app_database.g.dart';



@DriftDatabase(tables: [
  HabitLogsTable, // было ActionsTable
  HabitsTable,
  SessionsTable,
  SessionHabitsTable,
  DaysTable,
])
class AppDatabase extends _$AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();

  AppDatabase._internal() : super(_openConnection());

  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);

  @override
  int get schemaVersion => 6;

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
        if (from < 3) {
          await m.createTable(daysTable);
        }
        if (from < 4) {
          // Добавляем колонку для фиксации момента старта фазы контроля
          await m.addColumn(sessionsTable, sessionsTable.controlStartedAt);
        }
      },
    );
  }

  Future<List<int>> getSelectedHabitIdsForSession(String sessionId) async {
    final query = select(sessionHabitsTable)
      ..where((t) => t.sessionId.equals(sessionId));
    final rows = await query.get();
    return rows.map((row) => row.habitId).toList();
  }

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

  Future<void> deleteHabit(int habitId) async {
    await (delete(sessionHabitsTable)..where((t) => t.habitId.equals(habitId))).go();
    await (delete(habitLogsTable)..where((t) => t.habitId.equals(habitId))).go();
    await (delete(habitsTable)..where((t) => t.id.equals(habitId))).go();
  }

  // ===========================================================================
  // STREAM API
  // ===========================================================================

  /// Последняя сессия по createdAt. Использует watch() для надёжного
  /// триггера при UPDATE (watchSingleOrNull может пропускать обновления).
  Stream<SessionsTableData?> watchActiveSession() {
    return (select(sessionsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .watch()
        .map((rows) => rows.isEmpty ? null : rows.first);
  }

  Future<String?> getActiveSessionId() async {
    final query = select(sessionsTable)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row?.id;
  }

  Stream<List<HabitsTableData>> watchHabits() {
    return select(habitsTable).watch();
  }

  Stream<List<int>> watchSelectedHabitIds(String sessionId) {
    final query = select(sessionHabitsTable)
      ..where((t) => t.sessionId.equals(sessionId));
    return query.watch().map(
          (rows) => rows.map((row) => row.habitId).toList(),
        );
  }

  /// Наблюдает за записью дня по дате.
  /// Использует watch() + firstOrNull для надёжного триггера при UPDATE.
  Stream<DaysTableData?> watchDayLog(String dateStr) {
    return (select(daysTable)..where((t) => t.date.equals(dateStr)))
        .watch()
        .map((rows) => rows.isEmpty ? null : rows.first);
  }

  /// Баллы за клики в диапазоне [start, endExclusive).
  /// В фазе контроля start = controlStartedAt (не начало суток!) —
  /// чтобы исключить калибровочные клики из баланса.
  /// Суммирует scoreValue за [start, endExclusive).
  /// Использует watch() на всей таблице + map для надёжного триггера
  /// при каждом INSERT — selectOnly+watchSingle не всегда реагирует на вставки.
  // ЗАМЕНИТЬ метод целиком:
  Stream<int> watchScoreForDay(DateTime start, DateTime endExclusive) {
    final end = endExclusive.subtract(const Duration(microseconds: 1));
    final query = select(habitLogsTable).join([
      innerJoin(habitsTable, habitsTable.id.equalsExp(habitLogsTable.habitId)),
    ])
      ..where(habitLogsTable.timestamp.isBetweenValues(start, end));

    return query.watch().map(
          (rows) => rows.fold<int>(
        0,
            (sum, row) => sum + row.readTable(habitsTable).scoreValue,
      ),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}