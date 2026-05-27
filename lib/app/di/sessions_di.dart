import '../../features/sessions/data/repositories/session_repository_impl.dart';
import '../../features/sessions/domain/repositories/session_repository.dart';
import '../../features/sessions/domain/usecases/add_session_usecase.dart';
import '../../features/sessions/domain/usecases/get_sessions_by_day_usecase.dart';

class SessionsDI {
  late final SessionRepository repository;
  late final AddSessionUseCase addSessionUseCase;
  late final GetSessionsByDayUseCase getSessionsUseCase;

  SessionsDI() {
    repository = SessionRepositoryImpl();

    addSessionUseCase = AddSessionUseCase(repository);
    getSessionsUseCase = GetSessionsByDayUseCase(repository);
  }
}