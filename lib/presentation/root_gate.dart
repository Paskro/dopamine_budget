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
import 'package:dopamine_budget/features/sessions/domain/usecases/check_and_generate_weekly_report_usecase.dart';
import 'package:dopamine_budget/features/sessions/presentation/pages/weekly_report_page.dart';
import 'package:dopamine_budget/features/scoring/domain/usecases/get_weekly_habits_report_usecase.dart';

class RootGate extends StatefulWidget {
  final AppDatabase database;
  final SessionsNotifier sessionsNotifier;
  final HabitsNotifier habitsNotifier;
  final ScoringNotifier scoringNotifier;
  final ControlScreenNotifier controlScreenNotifier;
  final CheckAndGenerateWeeklyReportUseCase weeklyReportUseCase;
  final GetWeeklyHabitsReportUseCase getWeeklyHabitsReportUseCase;

  const RootGate({
    super.key,
    required this.database,
    required this.sessionsNotifier,
    required this.habitsNotifier,
    required this.scoringNotifier,
    required this.controlScreenNotifier,
    required this.weeklyReportUseCase,
    required this.getWeeklyHabitsReportUseCase,
  });

  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> with WidgetsBindingObserver {
  WeeklyReportData? _pendingWeeklyReport;

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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.controlScreenNotifier.checkForNewDay();
      _checkWeeklyReport();
    }
  }

  Future<void> _checkWeeklyReport() async {
    final session = widget.sessionsNotifier.state.currentSession;
    if (session == null || session.phase != 1) return;

    final report = await widget.weeklyReportUseCase.execute(session);
    if (report != null && mounted) {
      setState(() => _pendingWeeklyReport = report);
    }
  }

  Future<void> _markWeeklyReportReviewed() async {
    final report = _pendingWeeklyReport;
    final session = widget.sessionsNotifier.state.currentSession;
    if (report == null || session == null) return;

    final updated = session.copyWith(
      lastReviewedControlWeek: report.weekNumber,
    );
    await widget.sessionsNotifier.updateSession(updated);
    if (mounted) setState(() => _pendingWeeklyReport = null);
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

          if (session.phase == 1 && session.isReviewed) {
            // Проверяем при первом построении ControlScreen
            if (_pendingWeeklyReport == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) => _checkWeeklyReport());
            }

            content = _pendingWeeklyReport != null
                ? WeeklyReportPage(
              reportData: _pendingWeeklyReport!,
              onContinue: _markWeeklyReportReviewed,
              getWeeklyHabitsReportUseCase: widget.getWeeklyHabitsReportUseCase,
            )
                : ControlScreen(controlNotifier: widget.controlScreenNotifier);
          } else {
            content = HomePage(
              scoringNotifier: widget.scoringNotifier,
              habitsNotifier: widget.habitsNotifier,
            );
          }
        }

        return Stack(
          children: [
            content,
            DeveloperOverlay(
              onTimeShifted: () async {
                await widget.scoringNotifier.checkAndResetDayIfNeeded();
                widget.controlScreenNotifier.checkAndResetDayIfNeeded();
                await _checkWeeklyReport();
              },
            ),
          ],
        );
      },
    );
  }
}