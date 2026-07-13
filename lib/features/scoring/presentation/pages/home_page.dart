import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dopamine_budget/core/utils/time_provider.dart';
import 'package:dopamine_budget/features/scoring/presentation/state/scoring_notifier.dart';
import 'package:dopamine_budget/features/habits/presentation/state/habits_notifier.dart';
import '../../../habits/presentation/pages/habit_management_page.dart';
import '../../../sessions/presentation/pages/calibration_result_page.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/archive_session_use_case.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/delete_session_use_case.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/features/sessions/presentation/pages/session_summary_screen.dart';
import 'package:dopamine_budget/features/sessions/presentation/pages/profile_screen.dart';
import 'package:dopamine_budget/features/sessions/presentation/widgets/session_settings_sheet.dart';

class HomePage extends StatelessWidget {
  final ScoringNotifier scoringNotifier;
  final HabitsNotifier habitsNotifier;
  final Session session;
  final ArchiveSessionUseCase archiveSessionUseCase;
  final DeleteSessionUseCase deleteSessionUseCase;
  final SessionRepository sessionRepository;

  const HomePage({
    Key? key,
    required this.scoringNotifier,
    required this.habitsNotifier,
    required this.session,
    required this.archiveSessionUseCase,
    required this.deleteSessionUseCase,
    required this.sessionRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: scoringNotifier,
      builder: (context, child) {
        final currentSession = scoringNotifier.state.currentSession;

        if (currentSession != null &&
            currentSession.phase == 1 &&
            !currentSession.isReviewed) {
          return CalibrationResultPage(
            session: currentSession,
            scoringNotifier: scoringNotifier,
          );
        }

        return child!;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Дофаминовый Бюджет'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    sessionRepository: sessionRepository,
                    deleteSessionUseCase: deleteSessionUseCase,
                    activeSession: session,
                    habitsNotifier: habitsNotifier,
                    archiveSessionUseCase: archiveSessionUseCase,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => SessionSettingsSheet.show(
                context: context,
                session: session,
                habitsNotifier: habitsNotifier,
                scoringNotifier: scoringNotifier,
              ),
            ),
          ],
        ),
        body: ListenableBuilder(
          listenable: Listenable.merge([scoringNotifier, habitsNotifier]),
          builder: (context, child) {
            final activeHabits = habitsNotifier.habits.where((habit) {
              final habitIdInt = int.tryParse(habit.id);
              if (habitIdInt == null) return false;
              return habitsNotifier.selectedHabitIds.contains(habitIdInt);
            }).toList();

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    color: theme.colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            'Баланс на сегодня',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${scoringNotifier.state.pointsSpentToday} XP',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: scoringNotifier.state.isOverLimit
                                  ? Colors.red.shade700
                                  : Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Зафиксировать действие',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: activeHabits.isEmpty
                        ? Center(
                      child: Text(
                        'Нет выбранных привычек.\nНажмите на иконку сверху, чтобы добавить.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.grey),
                      ),
                    )
                        : ListView.separated(
                      itemCount: activeHabits.length,
                      separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final habit = activeHabits[index];

                        return DopamineHoldButton(
                          title: habit.title,
                          points: habit.scoreValue,
                          isLoading: habitsNotifier.isLoading,
                          onTriggered: () async {
                            await habitsNotifier.addActionLog(
                              habitId: habit.id,
                              points: habit.scoreValue,
                              timestamp: TimeProvider.now,
                            );
                            await scoringNotifier.refreshTodayState();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class DopamineHoldButton extends StatefulWidget {
  final String title;
  final int points;
  final bool isLoading;
  final VoidCallback onTriggered;

  const DopamineHoldButton({
    Key? key,
    required this.title,
    required this.points,
    required this.isLoading,
    required this.onTriggered,
  }) : super(key: key);

  @override
  State<DopamineHoldButton> createState() => _DopamineHoldButtonState();
}

class _DopamineHoldButtonState extends State<DopamineHoldButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  Duration get _holdDuration {
    if (widget.points <= 3) return const Duration(milliseconds: 600);
    if (widget.points <= 7) return const Duration(milliseconds: 1300);
    return const Duration(milliseconds: 2200);
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: _holdDuration);
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) _triggerSuccess();
    });
  }

  @override
  void didUpdateWidget(covariant DopamineHoldButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points) {
      _animationController.duration = _holdDuration;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _triggerSuccess() {
    _executeDifferentiatedHaptic();
    _animationController.reset();
    widget.onTriggered();
  }

  void _executeDifferentiatedHaptic() {
    if (widget.points <= 3) {
      HapticFeedback.lightImpact();
    } else if (widget.points <= 7) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.vibrate();
    }
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.isLoading) return;
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (_animationController.status != AnimationStatus.completed) {
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (_animationController.status != AnimationStatus.completed) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Stack(
        children: [
          Container(
            height: 62,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.15)),
            ),
          ),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FractionallySizedBox(
                widthFactor: _animationController.value,
                child: Container(
                  height: 62,
                  decoration: BoxDecoration(
                    color: widget.points >= 8
                        ? Colors.redAccent.withOpacity(0.25)
                        : theme.colorScheme.primary.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              );
            },
          ),
          Container(
            height: 62,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '-${widget.points} XP',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}