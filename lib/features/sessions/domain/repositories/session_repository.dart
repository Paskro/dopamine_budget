import '../entities/session.dart';

abstract class SessionRepository {
  Future<void> addSession(Session session);
Future<void> updateSession(Session session);
  Future<List<Session>> getSessionsByDay(DateTime date);


Future<int> getTotalScoreSpentByDay(DateTime date);
Future<void> recordActionLog({
  required String habitId,
  required int scoreCost,
  required DateTime createdAt,
});

  /// Баллы за каждый день начиная с даты старта сессии до сегодня
  Future<List<double>> getScoresPerDaySince(DateTime startDate);

  /// Топ-1 привычка по количеству срабатываний за период (COUNT по habitType)
  Future<String?> getMostFrequentHabitSince(DateTime startDate);

  /// Переводит сессию в фазу Контроля и сбрасывает флаг ознакомления
  Future<void> updateSessionToControl({required String sessionId});
}