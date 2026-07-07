import 'package:drift/drift.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import 'package:dopamine_budget/core/utils/time_provider.dart';
import 'package:dopamine_budget/features/streak/domain/entities/streak_record.dart';
import 'package:dopamine_budget/features/streak/domain/repositories/i_streak_repository.dart';
import 'package:dopamine_budget/features/streak/data/mappers/streak_mapper.dart';

class StreakRepositoryImpl implements IStreakRepository {
  final AppDatabase _db;

  StreakRepositoryImpl(this._db);

  @override
  Future<StreakRecord?> getStreak() async {
    final rows = await _db.select(_db.streakTable).get();
    if (rows.isEmpty) return null;
    return StreakMapper.fromDb(rows.first);
  }

  @override
  @override
  Future<void> syncStreak() async {
    final now = TimeProvider.now;
    final yesterdayStr = _formatDate(now.subtract(const Duration(days: 1)));

    await _db.transaction(() async {
      final rows = await _db.select(_db.streakTable).get();

      if (rows.isEmpty) {
        final hadActivity = await _hasActivityOnDate(yesterdayStr);
        await _db.into(_db.streakTable).insert(
          StreakTableCompanion.insert(
            lastActiveDate: yesterdayStr,
            currentMultiplier: const Value(1.0),
            previousMultiplier: const Value(1.0),
            isViewed: const Value(true),
            hadActivityYesterday: Value(hadActivity),
          ),
        );
        return;
      }

      final current = StreakMapper.fromDb(rows.first);
      if (current.lastActiveDate == yesterdayStr) return;

      var multiplier = current.currentMultiplier;
      final previousMultiplier = multiplier; // snapshot ДО цикла
      var cursor = DateTime.parse(current.lastActiveDate)
          .add(const Duration(days: 1));
      final target = DateTime.parse(yesterdayStr);

      bool hadActivityYesterday = false;
      while (!cursor.isAfter(target)) {
        final dateStr = _formatDate(cursor);
        final hasActivity = await _hasActivityOnDate(dateStr);
        if (dateStr == yesterdayStr) hadActivityYesterday = hasActivity;
        multiplier = hasActivity
            ? (multiplier + 0.05).clamp(1.0, 1.2)
            : (multiplier - 0.05).clamp(1.0, 1.2);
        cursor = cursor.add(const Duration(days: 1));
      }

      await (_db.update(_db.streakTable)
        ..where((t) => t.lastActiveDate.equals(current.lastActiveDate)))
          .write(StreakTableCompanion(
        lastActiveDate: Value(yesterdayStr),
        currentMultiplier: Value(multiplier),
        previousMultiplier: Value(previousMultiplier),
        isViewed: const Value(false),
        hadActivityYesterday: Value(hadActivityYesterday),
      ));
    });
  }

  @override
  Future<void> markViewed() async {
    final rows = await _db.select(_db.streakTable).get();
    if (rows.isEmpty) return;
    await (_db.update(_db.streakTable)
      ..where((t) => t.lastActiveDate.equals(rows.first.lastActiveDate)))
        .write(const StreakTableCompanion(isViewed: Value(true)));
  }

  Future<bool> _hasActivityOnDate(String dateStr) async {
    // Проверка кликов привычек
    final dateExpr = CustomExpression<String>(
      "date(${_db.habitLogsTable.actualTableName}.timestamp)",
    );
    final habitQuery = _db.selectOnly(_db.habitLogsTable)
      ..addColumns([dateExpr])
      ..where(dateExpr.equals(dateStr))
      ..limit(1);
    final habitRows = await habitQuery.get();
    if (habitRows.isNotEmpty) return true;

    // Проверка кнопок «Молодец» и «Сорвался» в DaysTable
    final dayQuery = _db.select(_db.daysTable)
      ..where((t) =>
      t.date.equals(dateStr) &
      (t.isGoodBoyClicked.equals(true) | t.isBrokenClicked.equals(true)))
      ..limit(1);
    final dayRows = await dayQuery.get();
    return dayRows.isNotEmpty;
  }

  String _formatDate(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
          '${dt.month.toString().padLeft(2, '0')}-'
          '${dt.day.toString().padLeft(2, '0')}';
}