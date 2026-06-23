import '../repositories/session_repository.dart';

class ArchiveSessionUseCase {
  final SessionRepository _repository;
  const ArchiveSessionUseCase(this._repository);

  Future<void> execute(String sessionId) =>
      _repository.updateSessionPhase(sessionId, 2);
}