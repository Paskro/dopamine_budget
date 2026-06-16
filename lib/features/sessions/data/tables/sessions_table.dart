import 'package:drift/drift.dart';

class SessionsTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get phase => integer()();
  RealColumn get avgScore => real().nullable()();
  BoolColumn get isReviewed => boolean().withDefault(const Constant(false))();
  BoolColumn get shouldDecrease => boolean().withDefault(const Constant(false))();
  RealColumn get decreasePercentage => real().nullable()();
  TextColumn get decreaseInterval => text().nullable()();
  IntColumn get calibrationDays => integer().withDefault(const Constant(3))();

  // Момент перехода в фазу контроля. null пока сессия в калибровке.
  // Используется для фильтрации ActionsTable — считаем только клики
  // ПОСЛЕ этой метки, чтобы не включать баллы калибровки в баланс контроля.
  DateTimeColumn get controlStartedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}