import 'package:drift/drift.dart';
import 'package:dopamine_budget/features/sessions/data/tables/sessions_table.dart';

class DaysTable extends Table {
  TextColumn get id => text()();
  TextColumn get date => text().customConstraint('UNIQUE NOT NULL')();
  TextColumn get sessionId => text().references(SessionsTable, #id, onDelete: KeyAction.cascade)();
  BoolColumn get isBrokenClicked => boolean().withDefault(const Constant(false))();
  BoolColumn get isGoodBoyClicked => boolean().withDefault(const Constant(false))();
  TextColumn get dayStatus => text().withDefault(const Constant('regular'))();
  BoolColumn get isWeeklyReportReviewed => boolean().withDefault(const Constant(false))();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}