import '../../../data/db/app_database.dart'; // Скорректируй путь к базе данных, если нужно
import '../../features/sessions/data/repositories/session_repository_impl.dart';
import '../../features/sessions/domain/repositories/session_repository.dart';
import '../../features/sessions/domain/usecases/add_session_usecase.dart';
import '../../features/sessions/domain/usecases/get_sessions_by_day_usecase.dart';

class SessionsDI {
  late final SessionRepository repository;
  late final AddSessionUseCase addSessionUseCase;
  late final GetSessionsByDayUseCase getSessionsUseCase;

  // Передаем сюда экземпляр базы данных
  SessionsDI(AppDatabase db) {
    repository = SessionRepositoryImpl(db);

    addSessionUseCase = AddSessionUseCase(repository);
    getSessionsUseCase = GetSessionsByDayUseCase(repository);
  }
}