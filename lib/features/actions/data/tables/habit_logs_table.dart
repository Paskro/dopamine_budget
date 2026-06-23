import 'package:drift/drift.dart';
import 'package:dopamine_budget/features/habits/data/tables/habits_table.dart';
import 'package:dopamine_budget/features/sessions/data/tables/sessions_table.dart';

class HabitLogsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId => integer().references(HabitsTable, #id)();
  TextColumn get sessionId => text().references(SessionsTable, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get timestamp => dateTime()();
}