import 'package:drift/drift.dart';

class ShrinkingPeriodsTable extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  TextColumn get startedAt => text()();
  TextColumn get endedAt => text().nullable()();
  RealColumn get baseLimit => real()();
  RealColumn get decreasePct => real()();
  IntColumn get intervalDays => integer()();
  TextColumn get updatedAt => text()();
  TextColumn get userId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}