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
import 'package:dopamine_budget/features/sessions/domain/usecases/archive_session_use_case.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/delete_session_use_case.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/check_and_generate_shrinking_report_usecase.dart';
import 'package:dopamine_budget/features/sessions/presentation/pages/shrinking_report_page.dart';

class RootGate extends StatefulWidget {
  final AppDatabase database;
  final SessionsNotifier sessionsNotifier;
  final HabitsNotifier habitsNotifier;
  final ScoringNotifier scoringNotifier;
  final ControlScreenNotifier controlScreenNotifier;
  final CheckAndGenerateWeeklyReportUseCase weeklyReportUseCase;
  final GetWeeklyHabitsReportUseCase getWeeklyHabitsReportUseCase;
  final ArchiveSessionUseCase archiveSessionUseCase;
  final DeleteSessionUseCase deleteSessionUseCase;
  final SessionRepository sessionRepository;
  final CheckAndGenerateShrinkingReportUseCase shrinkingReportUseCase;

  const RootGate({
    super.key,
    required this.database,
    required this.sessionsNotifier,
    required this.habitsNotifier,
    required this.scoringNotifier,
    required this.controlScreenNotifier,
    required this.weeklyReportUseCase,
    required this.getWeeklyHabitsReportUseCase,
    required this.archiveSessionUseCase,
    required this.deleteSessionUseCase,
    required this.sessionRepository,
    required this.shrinkingReportUseCase,
  });

  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> with WidgetsBindingObserver {
  WeeklyReportData? _pendingWeeklyReport;
  ShrinkingReportData? _pendingShrinkingReport;

  Future<void> _checkShrinkingReport() async {
    final session = widget.sessionsNotifier.state.currentSession;
    if (session == null || session.phase != 1) return;
    final report = await widget.shrinkingReportUseCase.execute();
    if (report != null && mounted) {
      setState(() => _pendingShrinkingReport = report);
    }
  }

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
      _checkShrinkingReport();
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
    if (report == null) return;
    await widget.sessionRepository.markWeeklyReportAsReviewed(report.weekEnd);
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
            sessionRepository: widget.sessionRepository,
            deleteSessionUseCase: widget.deleteSessionUseCase,
            onStartCalibration: (days) {
              widget.sessionsNotifier.restartCalibration(durationDays: days);
            },
            onStartControl: ({
              required limit,
              required shouldDecrease,
              percentage,
              interval,
              bool enableShrinking = false,
            }) async {
              try {
                await widget.sessionsNotifier.startManualControl(
                  limit: limit,
                  shouldDecrease: shouldDecrease,
                  decreasePercentage: percentage,
                  decreaseInterval: interval,
                );
                if (enableShrinking) {
                  await widget.scoringNotifier.toggleShrinking(true);
                }
              } catch (e) {
                debugPrint('[RootGate] onStartControl failed: $e');
              }
            },
          );
        } else {
          final session = state.currentSession!;

          if (session.phase == 1 && session.isReviewed) {
            // Проверяем при первом построении ControlScreen
            if (_pendingWeeklyReport == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) => _checkWeeklyReport());
            }
            if (_pendingShrinkingReport == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) => _checkShrinkingReport());
            }

            content = _pendingShrinkingReport != null
                ? ShrinkingReportPage(
              reportData: _pendingShrinkingReport!,
              sessionRepository: widget.sessionRepository,
              onContinue: () {
                if (mounted) setState(() => _pendingShrinkingReport = null);
              },
            )
                : _pendingWeeklyReport != null
                ? WeeklyReportPage(
              reportData: _pendingWeeklyReport!,
              onContinue: _markWeeklyReportReviewed,
              getWeeklyHabitsReportUseCase: widget.getWeeklyHabitsReportUseCase,
            )
                : ControlScreen(
              controlNotifier: widget.controlScreenNotifier,
              session: session,
              habitsNotifier: widget.habitsNotifier,
              archiveSessionUseCase: widget.archiveSessionUseCase,
              deleteSessionUseCase: widget.deleteSessionUseCase,
              sessionRepository: widget.sessionRepository,
              scoringNotifier: widget.scoringNotifier,
            );
          } else {
            content = HomePage(
              scoringNotifier: widget.scoringNotifier,
              habitsNotifier: widget.habitsNotifier,
              session: session,
              archiveSessionUseCase: widget.archiveSessionUseCase,
              deleteSessionUseCase: widget.deleteSessionUseCase,
              sessionRepository: widget.sessionRepository,
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
                await _checkShrinkingReport();
              },
            ),
          ],
        );
      },
    );
  }
}