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

}