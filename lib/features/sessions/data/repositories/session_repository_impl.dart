import 'package:drift/drift.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import '../mappers/session_mapper.dart';

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
        decreaseInterval: row.decreaseInterval != null ? (int.tryParse(row.decreaseInterval!) ?? 0) : null,
      );
    }).toList();
  }
  @override
  Future<void> updateSession(Session session) async {
    try {
      // 1. Конвертируем доменную модель в Companion для Drift
      final companion = SessionMapper.toDb(session);

      // 2. Обновляем строку в таблице базы данных по ID
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
      // Пишем Drift SQL-запрос: выбираем сессию, где нет даты окончания (активная)
      // или по бизнес-логике фаз берем первую запись, так как в MVP сессия одна активная.
      final query = _db.select(_db.sessionsTable)
        ..where((tbl) => tbl.id.isNotNull()) // Или твой специфичный флаг активности
        ..limit(1);

      final row = await query.getSingleOrNull();
      if (row == null) return null;

      // Маппим из Drift-строки в нашу доменную сущность Session
      return SessionMapper.fromDb(row);
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
      decreaseInterval: Value(session.decreaseInterval?.toString()),
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
        decreaseInterval: row.decreaseInterval != null ? (int.tryParse(row.decreaseInterval!) ?? 0) : 0,
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
          timestamp: createdAt, // 👈 используем переданное время
        ),
      );
    }
}