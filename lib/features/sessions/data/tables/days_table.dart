import 'package:drift/drift.dart';

class DaysTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Строго текстовый формат 'yyyy-MM-dd' — никаких DateTime в БД
  // UNIQUE гарантирует одну запись на день
  TextColumn get date => text().customConstraint('UNIQUE NOT NULL')();

  // FK → SessionsTable.id
  TextColumn get sessionId => text()();

  // DEPRECATED: не источник правды о срыве. Читать dayStatus == 'broken'.
  // Поле оставлено только для обратной совместимости старых записей в БД,
  // синхронизируется в markDayAsBroken, но никем не читается в новой логике.
  BoolColumn get isBrokenClicked =>
      boolean().withDefault(const Constant(false))();

  BoolColumn get isGoodBoyClicked =>
      boolean().withDefault(const Constant(false))();

  // 'regular' | 'ideal' | 'almost_ideal' | 'broken' — единственный источник
  // правды о состоянии дня. 'broken' терминален: дальнейшие переходы
  // запрещены на уровне репозитория (см. SessionRepositoryImpl:
  // markDayAsGoodBoy, logHabitClickWithStatusCheck).
  TextColumn get dayStatus =>
      text().withDefault(const Constant('regular'))();
}