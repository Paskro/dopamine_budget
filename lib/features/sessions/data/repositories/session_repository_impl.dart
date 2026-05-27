import 'package:drift/drift.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  final AppDatabase _db;

  SessionRepositoryImpl(this._db);

  // === 1. РЕАЛИЗАЦИЯ СТАРЫХ МЕТОДОВ ДЛЯ ИНТЕРФЕЙСА ===

  @override
  Future<void> addSession(Session session) async {
    // Вызываем наш метод сохранения, удовлетворяя контракт интерфейса
    await saveSession(session);
  }

  @override
  Future<List<Session>> getSessionsByDay(DateTime date) async {
    // Старая логика просила сессии за конкретный день.
    // Фильтруем записи в SQL по дате создания (createdAt)
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
        decreasePercentage: row.decreasePercentage,
        decreaseInterval: row.decreaseInterval,
      );
    }).toList();
  }

  // === 2. НАШИ НОВЫЕ МЕТОДЫ УПРАВЛЕНИЯ СЕССИЯМИ ===

  // Сохранение/обновление сессии в базу данных
  Future<void> saveSession(Session session) async {
    final companion = SessionsTableCompanion(
      id: Value(session.id),
      createdAt: Value(session.createdAt),
      phase: Value(session.phase),
      avgScore: Value(session.avgScore),
      shouldDecrease: Value(session.shouldDecrease),
      decreasePercentage: Value(session.decreasePercentage),
      decreaseInterval: Value(session.decreaseInterval),
    );

    await _db.into(_db.sessionsTable).insertOnConflictUpdate(companion);
  }

  // Получение вообще всех сессий из базы
  Future<List<Session>> getAllSessions() async {
    final rows = await _db.select(_db.sessionsTable).get();

    return rows.map((row) {
      return Session(
        id: row.id,
        createdAt: row.createdAt,
        phase: row.phase,
        avgScore: row.avgScore,
        shouldDecrease: row.shouldDecrease,
        decreasePercentage: row.decreasePercentage,
        decreaseInterval: row.decreaseInterval,
      );
    }).toList();
  }
}