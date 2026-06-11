import 'package:drift/drift.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/core/utils/time_provider.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/day_log.dart';
import 'package:dopamine_budget/features/sessions/data/mappers/day_log_mapper.dart';

// lib/features/sessions/data/repositories/session_repository_impl.dart

class SessionRepositoryImpl implements SessionRepository {
  final AppDatabase _db;

  SessionRepositoryImpl(this._db);

  // =========================================================================
  // SESSIONS
  // =========================================================================

  @override
  Future<void> addSession(Session session) async {
    await saveSession(session);
  }

  @override
  Future<void> updateSession(Session session) async {
    final companion = SessionsTableCompanion(
      id: Value(session.id),
      createdAt: Value(session.createdAt),
      phase: Value(session.phase),
      avgScore: Value(session.avgScore),
      shouldDecrease: Value(session.shouldDecrease),
      decreasePercentage: Value(session.decreasePercentage?.toDouble()),
      decreaseInterval: Value(session.decreaseInterval),
      isReviewed: Value(session.isReviewed),
      calibrationDays: Value(session.calibrationDays),
    );
    await (_db.update(_db.sessionsTable)
          ..where((t) => t.id.equals(session.id)))
        .write(companion);
  }

  @override
  Future<List<Session>> getSessionsByDay(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final rows = await (_db.select(_db.sessionsTable)
          ..where((tbl) =>
              tbl.createdAt.isBetweenValues(startOfDay, endOfDay)))
        .get();

    return rows.map(_sessionFromRow).toList();
  }

  @override
  Future<Session?> getActiveSession() async {
    final row = await (_db.select(_db.sessionsTable)..limit(1))
        .getSingleOrNull();
    return row == null ? null : _sessionFromRow(row);
  }

  @override
  Future<void> updateSessionToControl({required String sessionId}) async {
    await (_db.update(_db.sessionsTable)
          ..where((t) => t.id.equals(sessionId)))
        .write(const SessionsTableCompanion(
          phase: Value(1),
          isReviewed: Value(true),
        ));
  }

  @override
  Future<int> getTotalScoreSpentByDay(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final endOfDay =
        DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    final totalCostExpression = _db.actionsTable.scoreValue.sum();

    final query = _db.selectOnly(_db.actionsTable)
      ..addColumns([totalCostExpression])
      ..where(
          _db.actionsTable.timestamp.isBetweenValues(startOfDay, endOfDay));

    final row = await query.getSingle();
    return row.read(totalCostExpression) ?? 0;
  }

  @override
  Future<void> recordActionLog({
    required String habitId,
    required int scoreCost,
    required DateTime createdAt,
  }) async {
    await _db.into(_db.actionsTable).insert(
          ActionsTableCompanion.insert(
            habitType: habitId,
            scoreValue: scoreCost,
            timestamp: createdAt,
          ),
        );
  }

  @override
  Future<List<double>> getScoresPerDaySince(
      DateTime startDate, int maxDays) async {
    final results = <double>[];
    var current = DateTime(startDate.year, startDate.month, startDate.day);

    for (int i = 0; i < maxDays; i++) {
      final score = await getTotalScoreSpentByDay(current);
      results.add(score.toDouble());
      current = current.add(const Duration(days: 1));
    }

    return results;
  }

  @override
  Future<String?> getMostFrequentHabitSince(DateTime startDate) async {
    final startOfDay =
        DateTime(startDate.year, startDate.month, startDate.day);
    final endOfDay = TimeProvider.now;

    final countExpr = _db.actionsTable.id.count();

    final query = _db.selectOnly(_db.actionsTable)
      ..addColumns([_db.actionsTable.habitType, countExpr])
      ..where(
          _db.actionsTable.timestamp.isBetweenValues(startOfDay, endOfDay))
      ..groupBy([_db.actionsTable.habitType])
      ..orderBy([OrderingTerm.desc(countExpr)])
      ..limit(1);

    final row = await query.getSingleOrNull();
    return row?.read(_db.actionsTable.habitType);
  }

  @override
  Future<List<Map<String, int>>> getScoresPerHabitPerDay(
      DateTime startDate, int maxDays) async {
    final results = <Map<String, int>>[];
    var current = DateTime(startDate.year, startDate.month, startDate.day);

    for (int i = 0; i < maxDays; i++) {
      final startOfDay =
          DateTime(current.year, current.month, current.day, 0, 0, 0);
      final endOfDay =
          DateTime(current.year, current.month, current.day, 23, 59, 59, 999);

      final sumExpr = _db.actionsTable.scoreValue.sum();
      final query = _db.selectOnly(_db.actionsTable)
        ..addColumns([_db.actionsTable.habitType, sumExpr])
        ..where(_db.actionsTable.timestamp
            .isBetweenValues(startOfDay, endOfDay))
        ..groupBy([_db.actionsTable.habitType]);

      final rows = await query.get();
      final dayMap = <String, int>{};
      for (final row in rows) {
        final habit = row.read(_db.actionsTable.habitType) ?? '';
        final score = row.read(sumExpr) ?? 0;
        if (habit.isNotEmpty) dayMap[habit] = score;
      }

      results.add(dayMap);
      current = current.add(const Duration(days: 1));
    }

    return results;
  }

  // =========================================================================
  // DAYS TABLE
  // =========================================================================

  @override
  Future<DayLog?> getDayLog(DateTime date) async {
    final dateStr = DayLogMapper.dateToString(date);
    final row = await (_db.select(_db.daysTable)
          ..where((t) => t.date.equals(dateStr)))
        .getSingleOrNull();
    return row == null ? null : DayLogMapper.fromDb(row);
  }

  @override
  Future<DayLog> getOrCreateDayLog({
    required DateTime date,
    required String sessionId,
  }) async {
    final dateStr = DayLogMapper.dateToString(date);

    // Пробуем найти существующую запись
    final existing = await (_db.select(_db.daysTable)
          ..where((t) => t.date.equals(dateStr)))
        .getSingleOrNull();

    if (existing != null) return DayLogMapper.fromDb(existing);

    // Создаём новую запись — date UNIQUE гарантирует отсутствие дублей
    final companion = DaysTableCompanion.insert(
      date: dateStr,
      sessionId: sessionId,
    );
    final id = await _db.into(_db.daysTable).insert(companion);

    return DayLog(
      id: id,
      date: DateTime.parse(dateStr),
      sessionId: sessionId,
      isBrokenClicked: false,
      isGoodBoyClicked: false,
      dayStatus: 'regular',
    );
  }

  @override
  Future<void> markDayAsBroken(DateTime date) async {
    final dateStr = DayLogMapper.dateToString(date);
    await (_db.update(_db.daysTable)
          ..where((t) => t.date.equals(dateStr)))
        .write(const DaysTableCompanion(
          isBrokenClicked: Value(true),
        ));
  }

  @override
  Future<void> markDayAsGoodBoy(DateTime date) async {
    final dateStr = DayLogMapper.dateToString(date);
    await (_db.update(_db.daysTable)
          ..where((t) => t.date.equals(dateStr)))
        .write(const DaysTableCompanion(
          isGoodBoyClicked: Value(true),
          dayStatus: Value('ideal'),
        ));
  }

  /// Атомарная транзакция: клик привычки + деградация статуса ideal → almost_ideal.
  /// Race condition исключён — проверка и запись в одной СУБД-транзакции.
  @override
  Future<void> logHabitClickWithStatusCheck({
    required String habitId,
    required int scoreCost,
    required DateTime timestamp,
  }) async {
    await _db.transaction(() async {
      // 1. Записываем клик в ActionsTable
      await _db.into(_db.actionsTable).insert(
            ActionsTableCompanion.insert(
              habitType: habitId,
              scoreValue: scoreCost,
              timestamp: timestamp,
            ),
          );

      // 2. Атомарно проверяем и деградируем статус дня
      final dateStr = DayLogMapper.dateToString(timestamp);
      final dayRow = await (_db.select(_db.daysTable)
            ..where((t) => t.date.equals(dateStr)))
          .getSingleOrNull();

      if (dayRow != null && dayRow.dayStatus == 'ideal') {
        await (_db.update(_db.daysTable)
              ..where((t) => t.date.equals(dateStr)))
            .write(const DaysTableCompanion(
              dayStatus: Value('almost_ideal'),
            ));
      }
    });
  }

  // =========================================================================
  // PRIVATE HELPERS
  // =========================================================================

  Session _sessionFromRow(SessionsTableData row) {
    return Session(
      id: row.id,
      createdAt: row.createdAt,
      phase: row.phase,
      avgScore: row.avgScore,
      shouldDecrease: row.shouldDecrease,
      decreasePercentage: row.decreasePercentage?.toInt(),
      decreaseInterval: row.decreaseInterval,
      isReviewed: row.isReviewed,
      calibrationDays: row.calibrationDays,
    );
  }

  // Оставлено для обратной совместимости (вызывается из addSession)
  Future<void> saveSession(Session session) async {
    final companion = SessionsTableCompanion(
      id: Value(session.id),
      createdAt: Value(session.createdAt),
      phase: Value(session.phase),
      avgScore: Value(session.avgScore),
      shouldDecrease: Value(session.shouldDecrease),
      decreasePercentage: Value(session.decreasePercentage?.toDouble()),
      decreaseInterval: Value(session.decreaseInterval),
      isReviewed: Value(session.isReviewed),
      calibrationDays: Value(session.calibrationDays),
    );
    await _db.into(_db.sessionsTable).insertOnConflictUpdate(companion);
  }
}