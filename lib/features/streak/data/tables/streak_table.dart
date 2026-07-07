import 'package:drift/drift.dart';

class StreakTable extends Table {
  TextColumn get lastActiveDate => text()();
  RealColumn get currentMultiplier => real().withDefault(const Constant(1.0))();
  BoolColumn get isViewed => boolean().withDefault(const Constant(true))();
  BoolColumn get hadActivityYesterday => boolean().withDefault(const Constant(false))();
  RealColumn get previousMultiplier => real().withDefault(const Constant(1.0))();

  @override
  Set<Column> get primaryKey => {lastActiveDate};
}