// ЗАМЕНИТЬ весь файл:
import 'package:drift/drift.dart';
import 'package:dopamine_budget/features/sessions/data/tables/sessions_table.dart';

class DaysTable extends Table {
  // date — естественный PK, id убран
  TextColumn get date => text()();
  TextColumn get sessionId => text().references(SessionsTable, #id, onDelete: KeyAction.cascade)();
  BoolColumn get isBrokenClicked => boolean().withDefault(const Constant(false))();
  BoolColumn get isGoodBoyClicked => boolean().withDefault(const Constant(false))();
  TextColumn get dayStatus => text().withDefault(const Constant('regular'))();
  BoolColumn get isWeeklyReportReviewed => boolean().withDefault(const Constant(false))();
  TextColumn get updatedAt => text()();
  TextColumn get userId => text().nullable()();

  @override
  Set<Column> get primaryKey => {date};
}