import '../entities/session.dart';
import '../repositories/session_repository.dart';

class AddSessionUseCase {
  final SessionRepository repository;

  AddSessionUseCase(this.repository);

  Future<void> call(Session session) async {
    await repository.addSession(session);
  }
}