import 'package:drift/drift.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/core/utils/time_provider.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/day_log.dart';
import 'package:dopamine_budget/features/sessions/data/mappers/day_log_mapper.dart';
import 'package:dopamine_budget/features/sessions/data/mappers/shrinking_period_mapper.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/shrinking_period.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/day_stats.dart';


class SessionRepositoryImpl implements SessionRepository {
  final AppDatabase _db;

  SessionRepositoryImpl(this._db);

  // === 1. РЕАЛИЗАЦИЯ МЕТОДОВ ДЛЯ ИНТЕРФЕЙСА ===

  @override
  Future<void> addSession(Session session) async {
    await saveSession(session);
  }

  @override
  Future<List<Session>> getSessionsByDay(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final query = _db.select(_db.sessionsTable)
      ..where((tbl) => tbl.createdAt.isBetweenValues(startOfDay, endOfDay));

    final rows = await query.get();

    return rows.map(_sessionFromRow).toList();
  }

  @override
  Future<void> updateSession(Session session) async {
    try {
      final companion = SessionsTableCompanion(
        id: Value(session.id),
        createdAt: Value(session.createdAt),
        phase: Value(session.phase),
        avgScore: Value(session.avgScore),
        shouldDecrease: Value(session.shouldDecrease),
        isReviewed: Value(session.isReviewed),
        calibrationDays: Value(session.calibrationDays),
        controlStartedAt: Value(session.controlStartedAt),
        baseShrinkingLimit: Value(session.baseShrinkingLimit),
        shrinkingStartedAt: Value(session.shrinkingStartedAt),
        decreasePercentage: Value(session.decreasePercentage),
        decreaseIntervalDays: Value(session.decreaseIntervalDays),
        shrunkenLimit: Value(session.shrunkenLimit),
      );
      await (_db.update(_db.sessionsTable)
        ..where((t) => t.id.equals(session.id)))
          .write(companion);
      print('Сессия ${session.id} успешно обновлена в СУБД (фаза: ${session.phase})');
    } catch (e) {
      print('Ошибка выполнения updateSession в репозитории: $e');
      rethrow;
    }
  }

  @override
  @override
  Future<Session?> getActiveSession() async {
    final row = await (_db.select(_db.sessionsTable)
      ..where((t) => t.phase.isSmallerThanValue(2))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _sessionFromRow(row);
  }

  @override
  Future<List<DayLog>> getCompletedControlDays(String sessionId) async {
    final session = await getActiveSession();
    if (session?.controlStartedAt == null) return [];

    final today = DateTime(
      TimeProvider.now.year,
      TimeProvider.now.month,
      TimeProvider.now.day,
    );

    final controlStartStr = DayLogMapper.dateToString(session!.controlStartedAt!);

    final rows = await (_db.select(_db.daysTable)
      ..where((t) =>
      t.sessionId.equals(sessionId) &
      t.date.isBiggerOrEqualValue(controlStartStr))
      ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();

    return rows
        .map(DayLogMapper.fromDb)
        .where((d) => d.date.isBefore(today))
        .toList();
  }

  @override
  Future<Map<DateTime, int>> getScoresPerDateRange(
      DateTime from, DateTime to) async {
    final result = <DateTime, int>{};
    var current = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);

    while (!current.isAfter(end)) {
      final score = await getTotalScoreSpentByDay(current);
      result[current] = score;
      current = current.add(const Duration(days: 1));
    }

    return result;
  }

  @override
  Future<bool> hasHabitClicksForDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    final query = _db.select(_db.habitLogsTable)
      ..where((t) => t.timestamp.isBetweenValues(start, end))
      ..limit(1);

    final row = await query.getSingleOrNull();
    return row != null;
  }


  Future<int> getTotalScoreCostForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    final query = _db.select(_db.habitLogsTable).join([
      innerJoin(_db.habitsTable, _db.habitsTable.id.equalsExp(_db.habitLogsTable.habitId)),
    ])
      ..where(_db.habitLogsTable.timestamp.isBetweenValues(startOfDay, endOfDay));

    final rows = await query.get();
    return rows.fold<int>(0, (sum, row) => sum + row.readTable(_db.habitsTable).scoreValue);
  }

  // === 2. МЕТОДЫ УПРАВЛЕНИЯ СЕССИЯМИ ===

  Future<void> saveSession(Session session) async {
    final companion = SessionsTableCompanion(
      id: Value(session.id),
      createdAt: Value(session.createdAt),
      phase: Value(session.phase),
      avgScore: Value(session.avgScore),
      shouldDecrease: Value(session.shouldDecrease),
      isReviewed: Value(session.isReviewed),
      calibrationDays: Value(session.calibrationDays),
      controlStartedAt: Value(session.controlStartedAt),
      baseShrinkingLimit: Value(session.baseShrinkingLimit),
      shrinkingStartedAt: Value(session.shrinkingStartedAt),
      decreasePercentage: Value(session.decreasePercentage),
      decreaseIntervalDays: Value(session.decreaseIntervalDays),
      shrunkenLimit: Value(session.shrunkenLimit),
    );

    await _db.into(_db.sessionsTable).insertOnConflictUpdate(companion);
  }

  @override
  Future<void> updateShrinkingState({
    Value<double?> baseShrinkingLimit = const Value.absent(),
    Value<DateTime?> shrinkingStartedAt = const Value.absent(),
  }) async {
    final affectedRows = await (_db.update(_db.sessionsTable)
      ..where((t) => t.phase.isSmallerThanValue(2)))
        .write(SessionsTableCompanion(
      baseShrinkingLimit: baseShrinkingLimit,
      shrinkingStartedAt: shrinkingStartedAt,
    ));

    if (affectedRows == 0) throw StateError('Нет активной сессии');
  }

  Future<List<Session>> getAllSessions() async {
    final rows = await _db.select(_db.sessionsTable).get();
    return rows.map(_sessionFromRow).toList();
  }

  @override
  Future<int> getTotalScoreSpentByDay(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    final query = _db.select(_db.habitLogsTable).join([
      innerJoin(_db.habitsTable, _db.habitsTable.id.equalsExp(_db.habitLogsTable.habitId)),
    ])
      ..where(_db.habitLogsTable.timestamp.isBetweenValues(startOfDay, endOfDay));

    final rows = await query.get();
    return rows.fold<int>(0, (sum, row) => sum + row.readTable(_db.habitsTable).scoreValue);
  }

  @override
  Future<void> recordActionLog({
    required String habitId,
    required int scoreCost,
    required DateTime createdAt,
  }) async {
    final sessionId = await _db.getActiveSessionId();
    if (sessionId == null) {
      throw StateError('Нет активной сессии для записи действия');
    }
    await _db.into(_db.habitLogsTable).insert(
      HabitLogsTableCompanion.insert(
        habitId: int.parse(habitId),
        sessionId: sessionId,
        timestamp: createdAt,
      ),
    );
  }

  @override
  Future<List<double>> getScoresPerDaySince(DateTime startDate, int maxDays) async {
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
    final startOfDay = DateTime(startDate.year, startDate.month, startDate.day);
    final endOfDay = TimeProvider.now;

    final query = _db.select(_db.habitLogsTable).join([
      innerJoin(_db.habitsTable, _db.habitsTable.id.equalsExp(_db.habitLogsTable.habitId)),
    ])
      ..where(_db.habitLogsTable.timestamp.isBetweenValues(startOfDay, endOfDay));

    final rows = await query.get();
    final counts = <String, int>{};
    for (final row in rows) {
      final title = row.readTable(_db.habitsTable).title;
      counts[title] = (counts[title] ?? 0) + 1;
    }
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
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
  Future<List<Map<String, int>>> getScoresPerHabitPerDay(DateTime startDate, int maxDays) async {
    final results = <Map<String, int>>[];
    var current = DateTime(startDate.year, startDate.month, startDate.day);

    for (int i = 0; i < maxDays; i++) {
      final startOfDay = DateTime(current.year, current.month, current.day, 0, 0, 0);
      final endOfDay = DateTime(current.year, current.month, current.day, 23, 59, 59, 999);

      final query = _db.select(_db.habitLogsTable).join([
        innerJoin(_db.habitsTable, _db.habitsTable.id.equalsExp(_db.habitLogsTable.habitId)),
      ])
        ..where(_db.habitLogsTable.timestamp.isBetweenValues(startOfDay, endOfDay));

      final rows = await query.get();
      final dayMap = <String, int>{};
      for (final row in rows) {
        final habit = row.readTable(_db.habitsTable);
        dayMap[habit.title] = (dayMap[habit.title] ?? 0) + habit.scoreValue;
      }

      results.add(dayMap);
      current = current.add(const Duration(days: 1));
    }

    return results;
  }

  // =========================================================================
  // DAYS TABLE (legacy Future API)
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

    final existing = await (_db.select(_db.daysTable)
      ..where((t) => t.date.equals(dateStr)))
        .getSingleOrNull();

    if (existing != null) return DayLogMapper.fromDb(existing);

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
      isWeeklyReportReviewed: false,
    );
  }

  @override
  Future<void> markDayAsBroken(DateTime date) async {
    final dateStr = DayLogMapper.dateToString(date);
    await (_db.update(_db.daysTable)
      ..where((t) => t.date.equals(dateStr)))
        .write(const DaysTableCompanion(
      isBrokenClicked: Value(true), // deprecated alias, синхронизирован для совместимости
      dayStatus: Value('broken'),
    ));
  }

  @override
  Future<void> markDayAsGoodBoy(DateTime date) async {
    final dateStr = DayLogMapper.dateToString(date);

    // Guard: 'broken' терминален — UPDATE не затронет строку, если день
    // уже зафиксирован как сорванный. Предполагает, что строка для этой
    // даты уже существует (вызывающая сторона должна предварительно
    // позвать getOrCreateDayLog — см. ControlScreenNotifier.confirmGoodBoy).
    final affectedRows = await (_db.update(_db.daysTable)
      ..where((t) =>
      t.date.equals(dateStr) & t.dayStatus.equals('broken').not()))
        .write(const DaysTableCompanion(
      isGoodBoyClicked: Value(true),
      dayStatus: Value('ideal'),
    ));

    if (affectedRows == 0) {
      throw StateError(
        "markDayAsGoodBoy отклонён: день $dateStr уже зафиксирован как 'broken'.",
      );
    }
  }

  @override
  Future<void> logHabitClickWithStatusCheck({
    required String habitId,
    required int scoreCost,
    required DateTime timestamp,
  }) async {
    final dateStr = DayLogMapper.dateToString(timestamp);


    await _db.transaction(() async {
      final session = await (_db.select(_db.sessionsTable)
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
        ..limit(1))
          .getSingleOrNull();
      if (session == null) {
        throw StateError('Нет активной сессии для записи действия');
      }

      final dayRow = await (_db.select(_db.daysTable)
        ..where((t) => t.date.equals(dateStr)))
          .getSingleOrNull();

      if (dayRow != null && dayRow.dayStatus == 'broken') {
        throw StateError(
          "logHabitClickWithStatusCheck отклонён: день $dateStr уже зафиксирован как 'broken'.",
        );
      }

      await _db.into(_db.habitLogsTable).insert(
        HabitLogsTableCompanion.insert(
          habitId: int.parse(habitId),
          sessionId: session.id,
          timestamp: timestamp,
        ),
      );

      if (dayRow != null && dayRow.dayStatus == 'ideal') {
        await (_db.update(_db.daysTable)
          ..where((t) => t.date.equals(dateStr)))
            .write(const DaysTableCompanion(
          dayStatus: Value('almost_ideal'),
        ));
      }

      if (dayRow == null) {
        await _db.into(_db.daysTable).insert(
          DaysTableCompanion.insert(
            date: dateStr,
            sessionId: session.id,
          ),
        );
      }
    });
  }

  // =========================================================================
  // STREAM API — Single Source of Truth
  // =========================================================================

  @override
  Stream<Session?> watchActiveSession() {
    return _db.watchActiveSession().map(
          (row) => row == null ? null : _sessionFromRow(row),
    );
  }

  @override
  Stream<DayLog?> watchDayLog(DateTime date) {
    final dateStr = DayLogMapper.dateToString(date);
    return _db.watchDayLog(dateStr).map(
          (row) => row == null ? null : DayLogMapper.fromDb(row),
    );
  }

  @override
  Stream<int> watchScoreForDay(DateTime start, DateTime endExclusive) {
    return _db.watchScoreForDay(start, endExclusive);
  }

  @override
  Future<void> updateSessionPhase(String sessionId, int newPhase) async {
    await (_db.update(_db.sessionsTable)
      ..where((t) => t.id.equals(sessionId)))
        .write(SessionsTableCompanion(phase: Value(newPhase)));
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await (_db.delete(_db.sessionsTable)
      ..where((t) => t.id.equals(sessionId)))
        .go();
  }

  @override
  Future<List<Session>> getPastSessions() async {
    final rows = await (_db.select(_db.sessionsTable)
      ..where((t) => t.phase.equals(2))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    return rows.map(_sessionFromRow).toList();
  }

  @override
  Future<void> markWeeklyReportAsReviewed(DateTime date) async {
    final dateStr = DayLogMapper.dateToString(date);
    await (_db.update(_db.daysTable)
      ..where((t) => t.date.equals(dateStr)))
        .write(const DaysTableCompanion(
      isWeeklyReportReviewed: Value(true),
    ));
  }

  @override
  Future<ShrinkingPeriod?> getActiveShrinkingPeriod(String sessionId) async {
    final row = await (_db.select(_db.shrinkingPeriodsTable)
      ..where((t) => t.sessionId.equals(sessionId) & t.endedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.id)])
      ..limit(1))
        .getSingleOrNull();
    return row == null ? null : ShrinkingPeriodMapper.fromDb(row);
  }

  @override
  Future<void> insertShrinkingPeriod(ShrinkingPeriod period) async {
    await _db.into(_db.shrinkingPeriodsTable)
        .insert(ShrinkingPeriodMapper.toCompanion(period));
  }

  @override
  Future<void> closeShrinkingPeriod({
    required int periodId,
    required String endedAt,
    required double shrunkenLimit,
  }) async {
    await _db.transaction(() async {
      await (_db.update(_db.shrinkingPeriodsTable)
        ..where((t) => t.id.equals(periodId)))
          .write(ShrinkingPeriodsTableCompanion(endedAt: Value(endedAt)));

      await (_db.update(_db.sessionsTable)
        ..where((t) => t.phase.isSmallerThanValue(2)))
          .write(SessionsTableCompanion(
        shrunkenLimit: Value(shrunkenLimit),
        shrinkingStartedAt: const Value(null),
        decreasePercentage: const Value(null),
        decreaseIntervalDays: const Value(null),
      ));
    });
  }

  @override
  Future<bool> isShrinkingReportReviewed(String sessionId, DateTime periodStart) async {
    final dateStr = DayLogMapper.dateToString(periodStart);
    final row = await (_db.select(_db.shrinkingReportsLogTable)
      ..where((t) => t.sessionId.equals(sessionId) & t.periodWeekStart.equals(dateStr)))
        .getSingleOrNull();
    return row?.isReviewed ?? false;
  }

  @override
  Future<void> markShrinkingReportReviewed(String sessionId, DateTime periodStart) async {
    final dateStr = DayLogMapper.dateToString(periodStart);
    final existing = await (_db.select(_db.shrinkingReportsLogTable)
      ..where((t) => t.sessionId.equals(sessionId) & t.periodWeekStart.equals(dateStr)))
        .getSingleOrNull();

    if (existing != null) {
      await (_db.update(_db.shrinkingReportsLogTable)
        ..where((t) => t.id.equals(existing.id)))
          .write(const ShrinkingReportsLogTableCompanion(isReviewed: Value(true)));
    } else {
      await _db.into(_db.shrinkingReportsLogTable).insert(
        ShrinkingReportsLogTableCompanion.insert(
          sessionId: sessionId,
          periodWeekStart: dateStr,
          isReviewed: const Value(true),
        ),
      );
    }
  }

  @override
  Future<int> getShrinkingPeriodsCount(String sessionId) async {
    final rows = await (_db.select(_db.shrinkingPeriodsTable)
      ..where((t) => t.sessionId.equals(sessionId)))
        .get();
    return rows.length;
  }

  @override
  Future<List<DayStats>> getDayStatsForRange(DateTime from, DateTime to) async {
    final fromStr = DayLogMapper.dateToString(from);
    final toStr = DayLogMapper.dateToString(to);

    final dayRows = await (_db.select(_db.daysTable)
      ..where((t) => t.date.isBiggerOrEqualValue(fromStr) & t.date.isSmallerOrEqualValue(toStr)))
        .get();

    final startTs = DateTime(from.year, from.month, from.day);
    final endTs = DateTime(to.year, to.month, to.day, 23, 59, 59, 999);

    final logRows = await (_db.select(_db.habitLogsTable).join([
      innerJoin(_db.habitsTable, _db.habitsTable.id.equalsExp(_db.habitLogsTable.habitId)),
    ])..where(_db.habitLogsTable.timestamp.isBetweenValues(startTs, endTs))).get();

    final spentByDate = <String, int>{};
    for (final row in logRows) {
      final dateStr = DayLogMapper.dateToString(row.readTable(_db.habitLogsTable).timestamp);
      spentByDate[dateStr] = (spentByDate[dateStr] ?? 0) + row.readTable(_db.habitsTable).scoreValue;
    }

    final brokenByDate = <String, bool>{
      for (final d in dayRows) d.date: d.dayStatus == 'broken',
    };

    final results = <DayStats>[];
    var current = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    while (!current.isAfter(end)) {
      final dateStr = DayLogMapper.dateToString(current);
      results.add(DayStats(
        date: current,
        spent: spentByDate[dateStr] ?? 0,
        isBroken: brokenByDate[dateStr] ?? false,
      ));
      current = current.add(const Duration(days: 1));
    }
    return results;
  }

  // =========================================================================
  // PRIVATE HELPERS
  // =========================================================================

  @override
  Future<int> getCompletedCalibrationDaysCount(String sessionId) async {
    final today = DateTime(
      TimeProvider.now.year,
      TimeProvider.now.month,
      TimeProvider.now.day,
    );

    final rows = await (_db.select(_db.habitLogsTable)
      ..where((t) =>
      t.sessionId.equals(sessionId) &
      t.timestamp.isSmallerThanValue(today)))
        .get();

    final uniqueDates = rows
        .map((r) => DayLogMapper.dateToString(r.timestamp))
        .toSet();

    return uniqueDates.length;
  }

  Session _sessionFromRow(SessionsTableData row) {
    return Session(
      id: row.id,
      createdAt: row.createdAt,
      phase: row.phase,
      avgScore: row.avgScore,
      shouldDecrease: row.shouldDecrease,
      isReviewed: row.isReviewed,
      calibrationDays: row.calibrationDays,
      controlStartedAt: row.controlStartedAt,
      baseShrinkingLimit: row.baseShrinkingLimit,
      shrinkingStartedAt: row.shrinkingStartedAt,
      decreasePercentage: row.decreasePercentage,
      decreaseIntervalDays: row.decreaseIntervalDays,
      shrunkenLimit: row.shrunkenLimit,
    );
  }
}