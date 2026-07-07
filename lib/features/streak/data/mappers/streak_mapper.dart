import 'package:drift/drift.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import 'package:dopamine_budget/features/streak/domain/entities/streak_record.dart';

class StreakMapper {
  static StreakRecord fromDb(StreakTableData data) => StreakRecord(
    lastActiveDate: data.lastActiveDate,
    currentMultiplier: data.currentMultiplier,
    previousMultiplier: data.previousMultiplier,
    isViewed: data.isViewed,
    hadActivityYesterday: data.hadActivityYesterday,
  );

  static StreakTableCompanion toDb(StreakRecord record) => StreakTableCompanion(
    lastActiveDate: Value(record.lastActiveDate),
    currentMultiplier: Value(record.currentMultiplier),
    previousMultiplier: Value(record.previousMultiplier),
    isViewed: Value(record.isViewed),
    hadActivityYesterday: Value(record.hadActivityYesterday),
  );
}