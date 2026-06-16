import 'package:flutter/material.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import 'package:dopamine_budget/features/sessions/presentation/state/sessions_notifier.dart';
import 'package:dopamine_budget/features/sessions/presentation/pages/session_onboarding_screen.dart';
import 'package:dopamine_budget/features/habits/presentation/state/habits_notifier.dart';
import 'package:dopamine_budget/features/scoring/presentation/state/scoring_notifier.dart';
import 'package:dopamine_budget/features/scoring/presentation/pages/home_page.dart';
import 'package:dopamine_budget/features/sessions/presentation/pages/control_screen.dart';
import 'package:dopamine_budget/features/sessions/presentation/state/control_screen_notifier.dart';
import 'package:dopamine_budget/core/debug/developer_overlay.dart';

class RootGate extends StatefulWidget {
  final AppDatabase database;
  final SessionsNotifier sessionsNotifier;
  final HabitsNotifier habitsNotifier;
  final ScoringNotifier scoringNotifier;
  final ControlScreenNotifier controlScreenNotifier;

  const RootGate({
    super.key,
    required this.database,
    required this.sessionsNotifier,
    required this.habitsNotifier,
    required this.scoringNotifier,
    required this.controlScreenNotifier,
  });

  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // При возврате приложения на передний план — проверяем смену суток.
  // ControlScreenNotifier переподпишется на новый день автоматически.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.controlScreenNotifier.checkForNewDay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.sessionsNotifier,
      builder: (context, _) {
        final state = widget.sessionsNotifier.state;

        Widget content;

        if (state.isLoading) {
          content = const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state.currentSession == null) {
          content = SessionOnboardingScreen(
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
        } else {
          final session = state.currentSession!;
          // ControlScreen только если фаза==1 И итоги просмотрены.
          content = (session.phase == 1 && session.isReviewed)
              ? ControlScreen(controlNotifier: widget.controlScreenNotifier)
              : HomePage(
            scoringNotifier: widget.scoringNotifier,
            habitsNotifier: widget.habitsNotifier,
          );
        }

        return Stack(
          children: [
            content,
            DeveloperOverlay(
              onTimeShifted: () async {
                await widget.scoringNotifier.checkAndResetDayIfNeeded();
                widget.controlScreenNotifier.checkAndResetDayIfNeeded();
              },
            ),
          ],
        );
      },
    );
  }
}