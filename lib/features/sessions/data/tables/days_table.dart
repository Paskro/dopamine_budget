import 'package:drift/drift.dart';

// lib/features/sessions/data/tables/days_table.dart

class DaysTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Строго текстовый формат 'yyyy-MM-dd' — никаких DateTime в БД
  // UNIQUE гарантирует одну запись на день
  TextColumn get date => text().customConstraint('UNIQUE NOT NULL')();

  // FK → SessionsTable.id
  TextColumn get sessionId => text()();

  BoolColumn get isBrokenClicked =>
      boolean().withDefault(const Constant(false))();

  BoolColumn get isGoodBoyClicked =>
      boolean().withDefault(const Constant(false))();

  // 'regular' | 'ideal' | 'almost_ideal'
  TextColumn get dayStatus =>
      text().withDefault(const Constant('regular'))();
}