import '../entities/session.dart';
import '../entities/day_log.dart';

abstract class SessionRepository {
  // === SESSIONS (legacy Future API) ===

  Future<void> addSession(Session session);
  Future<void> updateSession(Session session);
  Future<List<Session>> getSessionsByDay(DateTime date);
  Future<Session?> getActiveSession();
  Future<void> updateSessionToControl({required String sessionId});

  Future<int> getTotalScoreSpentByDay(DateTime date);
  Future<void> recordActionLog({
    required String habitId,
    required int scoreCost,
    required DateTime createdAt,
  });

  Future<List<double>> getScoresPerDaySince(DateTime startDate, int maxDays);
  Future<String?> getMostFrequentHabitSince(DateTime startDate);
  Future<List<Map<String, int>>> getScoresPerHabitPerDay(
      DateTime startDate, int maxDays);

  // === DAYS TABLE (legacy Future API) ===

  Future<DayLog?> getDayLog(DateTime date);
  Future<DayLog> getOrCreateDayLog({
    required DateTime date,
    required String sessionId,
  });
  Future<void> markDayAsBroken(DateTime date);
  Future<void> markDayAsGoodBoy(DateTime date);
  Future<void> logHabitClickWithStatusCheck({
    required String habitId,
    required int scoreCost,
    required DateTime timestamp,
  });

  // ===========================================================================
  // STREAM API — Single Source of Truth.
  // Notifier'ы подписываются один раз в конструкторе и больше никогда
  // не вызывают ручной refresh()/loadX() после мутаций — обновление
  // приходит автоматически из БД.
  // ===========================================================================

  /// Текущая активная сессия (последняя по createdAt). null если сессий нет.
  Stream<Session?> watchActiveSession();

  /// Состояние дня (срыв/статус) за указанную дату. null если запись
  /// в DaysTable ещё не создана для этого дня.
  Stream<DayLog?> watchDayLog(DateTime date);

  /// Сумма баллов потраченных за указанные календарные сутки.
  /// [start] — начало суток, [endExclusive] — начало следующих суток.
  Stream<int> watchScoreForDay(DateTime start, DateTime endExclusive);
}