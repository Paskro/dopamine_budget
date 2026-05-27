import 'sessions_di.dart';
import 'scoring_di.dart';

class AppDI {
  late final SessionsDI sessions;
  late final ScoringDI scoring;

  AppDI() {
    sessions = SessionsDI();
    scoring = ScoringDI(sessions);
  }
}