import 'package:flutter/material.dart';
import 'package:dopamine_budget/features/sessions/presentation/state/sessions_notifier.dart';
import 'package:dopamine_budget/features/sessions/presentation/pages/session_onboarding_screen.dart';
import 'package:dopamine_budget/main.dart'; // Импортируем main, чтобы видеть HomePage
import 'package:dopamine_budget/features/habits/presentation/state/habits_notifier.dart';
import 'package:dopamine_budget/features/scoring/presentation/state/scoring_notifier.dart';

class RootGate extends StatelessWidget {
  final SessionsNotifier sessionsNotifier;
  final HabitsNotifier habitsNotifier;
  final ScoringNotifier scoringNotifier;

  const RootGate({
    super.key,
    required this.sessionsNotifier,
    required this.habitsNotifier,
    required this.scoringNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: sessionsNotifier,
      builder: (context, _) {
        final state = sessionsNotifier.state;

        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.currentSession == null) {
          return SessionOnboardingScreen(
            onStartCalibration: (days) {
              sessionsNotifier.restartCalibration(durationDays: days);
            },
            onStartControl: ({required limit, required shouldDecrease, percentage, interval}) {
              sessionsNotifier.startManualControl(
                limit: limit,
                shouldDecrease: shouldDecrease,
                decreasePercentage: percentage,
                decreaseInterval: interval,
              );
            },
          );
        }

        // Если сессия есть — пускаем на твою HomePage и передаем ей зависимости
        return HomePage(
          scoringNotifier: scoringNotifier,
          habitsNotifier: habitsNotifier,
        );
      },
    );
  }
}