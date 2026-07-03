import 'package:drift/drift.dart';

class ShrinkingReportsLogTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionId => text()();
  TextColumn get periodWeekStart => text()(); // 'yyyy-MM-dd'
  BoolColumn get isReviewed =>
      boolean().withDefault(const Constant(false))();
}