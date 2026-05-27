import '../entities/session.dart';
import '../repositories/session_repository.dart';

class GetSessionsByDayUseCase {
  final SessionRepository repository;

  GetSessionsByDayUseCase(this.repository);

  Future<List<Session>> call(DateTime date) async {
    return repository.getSessionsByDay(date);
  }
}