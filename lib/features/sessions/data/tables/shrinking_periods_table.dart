import 'package:drift/drift.dart';

class ShrinkingPeriodsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionId => text()();
  TextColumn get startedAt => text()(); // 'yyyy-MM-dd'
  TextColumn get endedAt => text().nullable()(); // null = активный период
  RealColumn get baseLimit => real()();
  RealColumn get decreasePct => real()(); // 0.02 = 2%
  IntColumn get intervalDays => integer()(); // 7 или 30
}