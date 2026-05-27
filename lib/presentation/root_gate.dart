import 'package:flutter/material.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import 'package:dopamine_budget/features/sessions/presentation/state/sessions_notifier.dart';
import 'package:dopamine_budget/features/sessions/presentation/pages/session_onboarding_screen.dart';
import 'package:dopamine_budget/main.dart';
import 'package:dopamine_budget/features/habits/presentation/state/habits_notifier.dart';
import 'package:dopamine_budget/features/scoring/presentation/state/scoring_notifier.dart';

class RootGate extends StatefulWidget {
  final AppDatabase database;
  final SessionsNotifier sessionsNotifier;
  final HabitsNotifier habitsNotifier;
  final ScoringNotifier scoringNotifier;

  const RootGate({
    super.key,
    required this.database,
    required this.sessionsNotifier,
    required this.habitsNotifier,
    required this.scoringNotifier,
  });

  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.sessionsNotifier.checkForNewDay();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.sessionsNotifier,
      builder: (context, _) {
        final state = widget.sessionsNotifier.state;

        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.currentSession == null) {
          return SessionOnboardingScreen(
            onStartCalibration: (days) {
              widget.sessionsNotifier.restartCalibration(durationDays: days);
            },
            onStartControl: ({required limit, required shouldDecrease, percentage, interval}) {
              widget.sessionsNotifier.startManualControl(
                limit: limit,
                shouldDecrease: shouldDecrease,
                decreasePercentage: percentage,
                decreaseInterval: interval,
              );
            },
          );
        }

        // Прокидываем базу данных и нотифайеры на главный экран
        return HomePage(
          database: widget.database,
          scoringNotifier: widget.scoringNotifier,
          habitsNotifier: widget.habitsNotifier,
        );
      },
    );
  }
}