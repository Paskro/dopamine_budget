import '../repositories/session_repository.dart';

class DeleteSessionUseCase {
  final SessionRepository _repository;
  const DeleteSessionUseCase(this._repository);

  Future<void> execute(String sessionId) =>
      _repository.deleteSession(sessionId);
}