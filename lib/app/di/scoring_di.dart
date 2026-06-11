import '../../../data/db/app_database.dart';
import '../../features/scoring/data/repositories/scoring_repository_impl.dart';
import '../../features/scoring/domain/repositories/scoring_repository.dart';
import '../../features/scoring/domain/usecases/calculate_score_usecase.dart';
import '../../features/scoring/domain/usecases/get_current_dopamine_balance_usecase.dart';
import '../../features/scoring/presentation/state/scoring_notifier.dart';
import '../../features/sessions/domain/usecases/verify_calibration_expiry_usecase.dart';
import 'sessions_di.dart';

class ScoringDI {
  late final ScoringRepository repository;
  late final CalculateScoreUseCase calculateScoreUseCase;
  late final VerifyCalibrationExpiryUseCase verifyCalibrationExpiryUseCase;
  late final GetCurrentDopamineBalanceUseCase getDopamineBalanceUseCase;
  late final ScoringNotifier scoringNotifier;

  ScoringDI(AppDatabase db, SessionsDI sessionsDI) {
    repository = ScoringRepositoryImpl(db);

    calculateScoreUseCase = CalculateScoreUseCase(repository);

    verifyCalibrationExpiryUseCase = VerifyCalibrationExpiryUseCase(
      sessionRepository: sessionsDI.repository,
      scoringRepository: repository,
    );

    getDopamineBalanceUseCase = GetCurrentDopamineBalanceUseCase(
      sessionRepository: sessionsDI.repository,
      scoringRepository: repository,
    );

    scoringNotifier = ScoringNotifier(
      calculateScoreUseCase: calculateScoreUseCase,
      sessionRepository: sessionsDI.repository,
      scoringRepository: repository,
      getSessionsUseCase: sessionsDI.getSessionsUseCase,
      verifyCalibrationExpiry: verifyCalibrationExpiryUseCase,
      getDopamineBalance: getDopamineBalanceUseCase,
    );
  }
}