// ЗАМЕНИТЬ весь файл:
import 'package:drift/drift.dart';

class StreakTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get lastActiveDate => text().unique()();
  RealColumn get currentMultiplier => real().withDefault(const Constant(1.0))();
  BoolColumn get isViewed => boolean().withDefault(const Constant(true))();
  BoolColumn get hadActivityYesterday => boolean().withDefault(const Constant(false))();
  RealColumn get previousMultiplier => real().withDefault(const Constant(1.0))();
  TextColumn get userId => text().nullable()();
  TextColumn get updatedAt => text().withDefault(const Constant(''))();
}