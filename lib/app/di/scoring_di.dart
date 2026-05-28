import '../../../data/db/app_database.dart'; // Путь к твоей базе данных drift
import '../../features/scoring/data/repositories/scoring_repository_impl.dart';
import '../../features/scoring/domain/repositories/scoring_repository.dart';
import '../../features/scoring/domain/usecases/calculate_score_usecase.dart';
import '../../features/scoring/presentation/state/scoring_notifier.dart';
import 'sessions_di.dart';

class ScoringDI {
  late final ScoringRepository repository;
  late final CalculateScoreUseCase calculateScoreUseCase;
  late final ScoringNotifier scoringNotifier;

  ScoringDI(AppDatabase db, SessionsDI sessionsDI) {
    // 1. Создаем репозиторий скоринга и передаем туда общую БД
    repository = ScoringRepositoryImpl(db);

    // 2. Создаем UseCase и передаем созданный репозиторий
    calculateScoreUseCase = CalculateScoreUseCase(repository);

    // 3. Собираем финальный Нотификатор состояния для UI
    scoringNotifier = ScoringNotifier(
      sessionRepository: sessionsDI.repository,
      getSessionsUseCase: sessionsDI.getSessionsUseCase,
      calculateScoreUseCase: calculateScoreUseCase,
    );
  }
}