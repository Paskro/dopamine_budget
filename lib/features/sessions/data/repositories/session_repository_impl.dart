import 'package:drift/drift.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/core/utils/time_provider.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';

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

    return rows.map((row) {
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
    }).toList();
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
        decreasePercentage: Value(session.decreasePercentage?.toDouble()),
        decreaseInterval: Value(session.decreaseInterval),
        isReviewed: Value(session.isReviewed),
        calibrationDays: Value(session.calibrationDays),
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


    Future<Session?> getActiveSession() async {
      final query = _db.select(_db.sessionsTable)
        ..where((tbl) => tbl.id.isNotNull())
        ..limit(1);
      final row = await query.getSingleOrNull();
      if (row == null) return null;
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


    Future<int> getTotalScoreCostForDate(DateTime date) async {
      // Нам нужно посчитать сумму баллов за конкретные сутки.
      // Так как в БД timestamps хранятся с часами/минутами/секундами,
      // мы фильтруем логи в диапазоне: от 00:00:00 выбранного дня до 23:59:59.

      final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

      // Создаем переменную для агрегирующей функции SUM(score_value)
      final totalCostExpression = _db.actionsTable.scoreValue.sum();

      final query = _db.selectOnly(_db.actionsTable)
        ..addColumns([totalCostExpression])
        ..where(_db.actionsTable.timestamp.isBetweenValues(startOfDay, endOfDay));

      final row = await query.getSingle();

      // Возвращаем результат суммы. Если логов за день нет, Drift вернет null, тогда отдаем 0.
      return row.read(totalCostExpression) ?? 0;
    }

  // === 2. МЕТОДЫ УПРАВЛЕНИЯ СЕССИЯМИ ===

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

  Future<List<Session>> getAllSessions() async {
    final rows = await _db.select(_db.sessionsTable).get();

    return rows.map((row) {
      return Session(
        id: row.id,
        createdAt: row.createdAt,
        phase: row.phase,
        avgScore: row.avgScore,
        shouldDecrease: row.shouldDecrease,
        decreasePercentage: row.decreasePercentage?.toInt() ?? 0,
        decreaseInterval: row.decreaseInterval,
        isReviewed: row.isReviewed,
        calibrationDays: row.calibrationDays,
      );
    }).toList();
  }
  @override
    Future<int> getTotalScoreSpentByDay(DateTime date) async {
      final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

      final totalCostExpression = _db.actionsTable.scoreValue.sum();

      final query = _db.selectOnly(_db.actionsTable)
        ..addColumns([totalCostExpression])
        ..where(_db.actionsTable.timestamp.isBetweenValues(startOfDay, endOfDay));

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

  /// Возвращает список суммарных баллов за каждый день начиная с [startDate] до сегодня
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

  /// Топ-1 привычка по COUNT(id) GROUP BY habitType за период с [startDate]
  @override
  Future<String?> getMostFrequentHabitSince(DateTime startDate) async {
    final startOfDay = DateTime(startDate.year, startDate.month, startDate.day);
    final endOfDay = TimeProvider.now;

    final countExpr = _db.actionsTable.id.count();

    final query = _db.selectOnly(_db.actionsTable)
      ..addColumns([_db.actionsTable.habitType, countExpr])
      ..where(_db.actionsTable.timestamp.isBetweenValues(startOfDay, endOfDay))
      ..groupBy([_db.actionsTable.habitType])
      ..orderBy([OrderingTerm.desc(countExpr)])
      ..limit(1);

    final row = await query.getSingleOrNull();
    return row?.read(_db.actionsTable.habitType);
  }

  /// Переводит сессию в фазу Контроля (phase=1) и помечает как ознакомленную (isReviewed=true)
  @override
  Future<void> updateSessionToControl({required String sessionId}) async {
    await (_db.update(_db.sessionsTable)
          ..where((t) => t.id.equals(sessionId)))
        .write(const SessionsTableCompanion(
          phase: Value(1),
          isReviewed: Value(true),
        ));
  }

  /// Баллы по каждой привычке за каждый день с [startDate] до сегодня
  @override
  Future<List<Map<String, int>>> getScoresPerHabitPerDay(DateTime startDate, int maxDays) async {
    final results = <Map<String, int>>[];
    var current = DateTime(startDate.year, startDate.month, startDate.day);

    for (int i = 0; i < maxDays; i++) {
      final startOfDay = DateTime(current.year, current.month, current.day, 0, 0, 0);
      final endOfDay = DateTime(current.year, current.month, current.day, 23, 59, 59, 999);

      final sumExpr = _db.actionsTable.scoreValue.sum();
      final query = _db.selectOnly(_db.actionsTable)
        ..addColumns([_db.actionsTable.habitType, sumExpr])
        ..where(_db.actionsTable.timestamp.isBetweenValues(startOfDay, endOfDay))
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
}