import '../entities/session.dart';

abstract class SessionRepository {
  Future<void> addSession(Session session);
Future<void> updateSession(Session session);
  Future<List<Session>> getSessionsByDay(DateTime date);
}