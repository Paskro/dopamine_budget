import '../../features/scoring/presentation/state/scoring_notifier.dart';
import 'sessions_di.dart';

class ScoringDI {
  late final ScoringNotifier notifier;

  ScoringDI(SessionsDI sessionsDI) {
    notifier = ScoringNotifier(
      addSessionUseCase: sessionsDI.addSessionUseCase,
      getSessionsUseCase: sessionsDI.getSessionsUseCase,
    );
  }
}