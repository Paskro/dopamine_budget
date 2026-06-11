import '../../../data/db/app_database.dart';
import '../../features/sessions/data/repositories/session_repository_impl.dart';
import '../../features/sessions/domain/repositories/session_repository.dart';
import '../../features/sessions/domain/usecases/add_session_usecase.dart';
import '../../features/sessions/domain/usecases/get_sessions_by_day_usecase.dart';
import '../../features/sessions/domain/usecases/initialize_session_usecase.dart';
import '../../features/sessions/domain/usecases/start_control_session_usecase.dart';
import '../../features/scoring/domain/usecases/get_current_dopamine_balance_usecase.dart';
import 'control_screen_di.dart'; // ← лежит рядом в app/di/

class SessionsDI {
  late final SessionRepository repository;
  late final AddSessionUseCase addSessionUseCase;
  late final GetSessionsByDayUseCase getSessionsUseCase;
  late final InitializeSessionUseCase initializeSessionUseCase;
  late final StartControlSessionUseCase startControlSessionUseCase;

  late final ControlScreenDI controlScreenDI;

  SessionsDI(AppDatabase db) {
    repository = SessionRepositoryImpl(db);
    addSessionUseCase = AddSessionUseCase(repository);
    getSessionsUseCase = GetSessionsByDayUseCase(repository);
    initializeSessionUseCase = InitializeSessionUseCase(repository);
    startControlSessionUseCase = StartControlSessionUseCase(repository);
  }

  void initControlScreen(GetCurrentDopamineBalanceUseCase getDopamineBalance) {
    controlScreenDI = ControlScreenDI(
      sessionRepository: repository,
      getDopamineBalance: getDopamineBalance,
    );
  }
}