import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import 'package:dopamine_budget/features/habits/data/tables/habits_table.dart';
import 'package:dopamine_budget/features/actions/data/tables/habit_logs_table.dart';
import 'package:dopamine_budget/features/sessions/data/tables/sessions_table.dart';
import 'package:dopamine_budget/features/sessions/data/tables/days_table.dart';
import 'package:dopamine_budget/features/sessions/data/tables/shrinking_periods_table.dart';
import 'package:dopamine_budget/features/sessions/data/tables/shrinking_reports_log_table.dart';
import 'package:dopamine_budget/features/streak/data/tables/streak_table.dart';

part 'app_database.g.dart';



@DriftDatabase(tables: [
  HabitLogsTable,
  HabitsTable,
  SessionsTable,
  SessionHabitsTable,
  DaysTable,
  ShrinkingPeriodsTable,
  ShrinkingReportsLogTable,
  StreakTable,
])
class AppDatabase extends _$AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();

  AppDatabase._internal() : super(_openConnection());

  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);

  @override
  int get schemaVersion => 13;

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
        if (from < 8) {
          await m.recreateAllViews();
          // Drift не умеет ALTER CONSTRAINT — пересоздаём таблицы с новым FK
          await m.drop(habitLogsTable);
          await m.drop(daysTable);
          await m.createTable(habitLogsTable);
          await m.createTable(daysTable);
        }
        if (from < 9) {
          await m.createTable(shrinkingPeriodsTable);
          await m.createTable(shrinkingReportsLogTable);
          await m.addColumn(sessionsTable, sessionsTable.shrunkenLimit);
        }
        if (from < 10) {
          await m.createTable(streakTable);
        }
        if (from < 11) {
          await m.addColumn(streakTable, streakTable.hadActivityYesterday as GeneratedColumn);
        }
        if (from < 12) {
          await m.addColumn(streakTable, streakTable.previousMultiplier as GeneratedColumn);
        }
        if (from < 13) {
          // UUID-миграция: пересоздаём все таблицы с int PK
          // Данные НЕ мигрируем — сброс (devmode, prod-данных ещё нет)
          await m.drop(habitLogsTable);
          await m.drop(sessionHabitsTable);
          await m.drop(habitsTable);
          await m.drop(daysTable);
          await m.drop(shrinkingPeriodsTable);
          await m.drop(shrinkingReportsLogTable);
          // sessions и streak не пересоздаём — только addColumn
          await m.createTable(habitsTable);
          await m.createTable(sessionHabitsTable);
          await m.createTable(habitLogsTable);
          await m.createTable(daysTable);
          await m.createTable(shrinkingPeriodsTable);
          await m.createTable(shrinkingReportsLogTable);
          await m.addColumn(sessionsTable, sessionsTable.updatedAt);
          await m.addColumn(sessionsTable, sessionsTable.isDeleted);
        }
      },
    );
  }

  Future<List<String>> getSelectedHabitIdsForSession(String sessionId) async {
    final query = select(sessionHabitsTable)
      ..where((t) => t.sessionId.equals(sessionId));
    final rows = await query.get();
    return rows.map((row) => row.habitId).toList();
  }

  Future<void> toggleHabitSelection(String sessionId, String habitId) async {
    final query = select(sessionHabitsTable)
      ..where((t) => t.sessionId.equals(sessionId) & t.habitId.equals(habitId));
    final existing = await query.getSingleOrNull();

    if (existing != null) {
      await (delete(sessionHabitsTable)..where((t) => t.id.equals(existing.id))).go();
    } else {
      await into(sessionHabitsTable).insert(
        SessionHabitsTableCompanion.insert(
          id: const Uuid().v4(),
          sessionId: sessionId,
          habitId: habitId,
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );
    }
  }

  Future<void> archiveHabit(String habitId) async {
    await (update(habitsTable)..where((t) => t.id.equals(habitId))).write(
      HabitsTableCompanion(
        isArchived: const Value(true),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
    await (delete(sessionHabitsTable)..where((t) => t.habitId.equals(habitId))).go();
  }

  // ===========================================================================
  // STREAM API
  // ===========================================================================

  /// Последняя сессия по createdAt. Использует watch() для надёжного
  /// триггера при UPDATE (watchSingleOrNull может пропускать обновления).
  Stream<SessionsTableData?> watchActiveSession() {
    return (select(sessionsTable)
      ..where((t) => t.phase.isSmallerThanValue(2))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(1))
        .watch()
        .map((rows) => rows.isEmpty ? null : rows.first);
  }

  Future<String?> getActiveSessionId() async {
    final row = await (select(sessionsTable)
      ..where((t) => t.phase.isSmallerThanValue(2))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(1))
        .getSingleOrNull();
    return row?.id;
  }

  Stream<List<HabitsTableData>> watchHabits() {
    return (select(habitsTable)..where((t) => t.isArchived.equals(false))).watch();
  }

  Stream<List<String>> watchSelectedHabitIds(String sessionId) {
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
    return NativeDatabase(
      file,
      setup: (rawDb) {
        rawDb.execute('PRAGMA foreign_keys = ON;');
      },
    );
  });
}