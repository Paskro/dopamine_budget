import 'package:drift/drift.dart';

class SessionsTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get phase => integer()();
  RealColumn get avgScore => real().nullable()();
  BoolColumn get isReviewed => boolean().withDefault(const Constant(false))();
  BoolColumn get shouldDecrease => boolean().withDefault(const Constant(false))();
  IntColumn get calibrationDays => integer().withDefault(const Constant(3))();
  DateTimeColumn get controlStartedAt => dateTime().nullable()();

  // Shrinking Mode (ТЗ v3)
  RealColumn get baseShrinkingLimit => real().nullable()();
  DateTimeColumn get shrinkingStartedAt => dateTime().nullable()();
  RealColumn get decreasePercentage => real().nullable()();
  IntColumn get decreaseIntervalDays => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}