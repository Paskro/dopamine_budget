import 'package:drift/drift.dart';

class ShrinkingReportsLogTable extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  TextColumn get periodWeekStart => text()();
  BoolColumn get isReviewed => boolean().withDefault(const Constant(false))();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}