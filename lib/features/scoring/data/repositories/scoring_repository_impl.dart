import 'package:drift/drift.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import '../../domain/repositories/scoring_repository.dart';

class ScoringRepositoryImpl implements ScoringRepository {
  final AppDatabase _db;

  ScoringRepositoryImpl(this._db);

  @override
  Future<void> saveAction({
    required String habitType,
    required int scoreValue,
    required DateTime timestamp,
  }) async {
    await _db.into(_db.actionsTable).insert(
          ActionsTableCompanion.insert(
            habitType: habitType,
            scoreValue: scoreValue,
            timestamp: timestamp,
          ),
        );
  }

  @override
  Future<int> getScoreForDay(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final query = _db.selectOnly(_db.actionsTable)
      ..addColumns([_db.actionsTable.scoreValue.sum()])
      ..where(_db.actionsTable.timestamp.isBetweenValues(startOfDay, endOfDay));

    final row = await query.getSingle();
    return row.read(_db.actionsTable.scoreValue.sum()) ?? 0;
  }

  @override
  Future<Map<String, int>> getHabitClicksForDay(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final amountOfClicks = _db.actionsTable.id.count();

    final query = _db.selectOnly(_db.actionsTable)
      ..addColumns([_db.actionsTable.habitType, amountOfClicks])
      ..where(_db.actionsTable.timestamp.isBetweenValues(startOfDay, endOfDay))
      ..groupBy([_db.actionsTable.habitType]);

    final rows = await query.get();

    final Map<String, int> result = {};
    for (final row in rows) {
      final type = row.read(_db.actionsTable.habitType);
      final count = row.read(amountOfClicks);
      if (type != null && count != null) {
        result[type] = count;
      }
    }
    return result;
  }
}