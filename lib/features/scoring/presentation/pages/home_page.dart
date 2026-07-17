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
import 'package:dopamine_budget/core/utils/haptic_service.dart';

// ─── Цвета дизайн-системы ────────────────────────────────────────────────────
const _bg         = Color(0xFF1A2421);
const _surface    = Color(0xFF24342F);
const _surfaceEl  = Color(0xFF2A3D37);
const _textPri    = Color(0xFFF2EFEA);
const _textSec    = Color(0xFFA8B5AF);
const _textDis    = Color(0xFF6E7A75);
const _gold       = Color(0xFFD3A26D);
const _goldBg     = Color(0x26D3A26D);   // 15% opacity
const _goldBorder = Color(0x59D3A26D);   // 35% opacity

// Золотой стиль — единый для иконки профиля, «Подробнее», цифр привычек, FAB
BoxDecoration get _goldDecoration => BoxDecoration(
  color: _goldBg,
  borderRadius: BorderRadius.circular(100),
  border: Border.all(color: _goldBorder),
  boxShadow: const [BoxShadow(color: Color(0x2ED3A26D), blurRadius: 8, spreadRadius: 1)],
);

// ─── HomePage ─────────────────────────────────────────────────────────────────
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
      child: _CalibrationHomeBody(
        scoringNotifier: scoringNotifier,
        habitsNotifier: habitsNotifier,
        session: session,
        archiveSessionUseCase: archiveSessionUseCase,
        deleteSessionUseCase: deleteSessionUseCase,
        sessionRepository: sessionRepository,
      ),
    );
  }
}

// ─── Основной экран калибровки ────────────────────────────────────────────────
class _CalibrationHomeBody extends StatefulWidget {
  final ScoringNotifier scoringNotifier;
  final HabitsNotifier habitsNotifier;
  final Session session;
  final ArchiveSessionUseCase archiveSessionUseCase;
  final DeleteSessionUseCase deleteSessionUseCase;
  final SessionRepository sessionRepository;

  const _CalibrationHomeBody({
    required this.scoringNotifier,
    required this.habitsNotifier,
    required this.session,
    required this.archiveSessionUseCase,
    required this.deleteSessionUseCase,
    required this.sessionRepository,
  });

  @override
  State<_CalibrationHomeBody> createState() => _CalibrationHomeBodyState();
}

class _CalibrationHomeBodyState extends State<_CalibrationHomeBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  int _completedDays = 0;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadCompletedDays();
    widget.scoringNotifier.addListener(_loadCompletedDays);
  }

  @override
  void dispose() {
    widget.scoringNotifier.removeListener(_loadCompletedDays);
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCompletedDays() async {
    final sessionId = widget.scoringNotifier.state.currentSessionId;
    if (sessionId == null || sessionId.isEmpty) return;
    final count = await widget.sessionRepository
        .getCompletedCalibrationDaysCount(sessionId);
    if (mounted && count != _completedDays) {
      setState(() => _completedDays = count);
    }
  }


  void _openDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _DetailSheet(
        habitClicksToday: widget.scoringNotifier.state.habitClicksToday,
        habits: widget.habitsNotifier.habits,
      ),
    );
  }

  void _openSettings(BuildContext context) {
    SessionSettingsSheet.show(
      context: context,
      session: widget.session,
      habitsNotifier: widget.habitsNotifier,
      scoringNotifier: widget.scoringNotifier,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: ListenableBuilder(
            listenable: Listenable.merge(
                [widget.scoringNotifier, widget.habitsNotifier]),
            builder: (context, _) {
              final state = widget.scoringNotifier.state;
              final session = state.currentSession ?? widget.session;
              final activeHabits =
              widget.habitsNotifier.habits.where((h) {
                final id = int.tryParse(h.id);
                return id != null &&
                    widget.habitsNotifier.selectedHabitIds.contains(id);
              }).toList();

              return Column(
                children: [
                  _AppBar(
                    onProfileTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(
                          sessionRepository: widget.sessionRepository,
                          deleteSessionUseCase: widget.deleteSessionUseCase,
                          activeSession: widget.session,
                          habitsNotifier: widget.habitsNotifier,
                          archiveSessionUseCase: widget.archiveSessionUseCase,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          _CalibrationDots(
                            totalDays: session.calibrationDays,
                            completedDays: _completedDays,
                          ),
                          const SizedBox(height: 16),
                          _ActivityCard(
                            pointsToday: state.pointsSpentToday,
                            onDetailsTap: () => _openDetails(context),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Ваши привычки',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _textPri,
                              letterSpacing: 0.01,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: activeHabits.isEmpty
                                ? _EmptyHabits(
                                onAddTap: () => _openSettings(context))
                                : _HabitList(
                              habits: activeHabits,
                              habitsNotifier: widget.habitsNotifier,
                              scoringNotifier: widget.scoringNotifier,
                            ),
                          ),
                          _FabAdd(onTap: () => _openSettings(context)),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Кол-во завершённых дней = уникальные дни с кликами до сегодня
  // ScoringNotifier не даёт нам этот список напрямую — используем
  // habitClicksToday как индикатор активности сегодня, а completedDays
  // считаем через вспомогательный метод нотифаера если доступен.
  // Здесь используем заглушку — реальное значение придёт из SessionRepository.

}

// ─── AppBar ───────────────────────────────────────────────────────────────────
class _AppBar extends StatelessWidget {
  final VoidCallback onProfileTap;
  const _AppBar({required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(
        children: [
          const Spacer(),
          const Text(
            'Self-Observation',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _textPri,
              letterSpacing: 0.01,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onProfileTap,
            child: Container(
              width: 36,
              height: 36,
              decoration: _goldDecoration,
              child: const Icon(_UserIcon.person, color: _gold, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Точки прогресса ──────────────────────────────────────────────────────────
class _CalibrationDots extends StatefulWidget {
  final int totalDays;
  final int completedDays; // дней с кликами (без сегодня)

  const _CalibrationDots({
    required this.totalDays,
    required this.completedDays,
  });

  @override
  State<_CalibrationDots> createState() => _CalibrationDotsState();
}

class _CalibrationDotsState extends State<_CalibrationDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.totalDays.clamp(3, 14);
    if (n <= 7) {
      return _buildRow(0, n);
    }
    // 14 дней: два ряда по 7
    return Column(
      children: [
        _buildRow(0, 7),
        const SizedBox(height: 8),
        _buildRow(7, 7),
      ],
    );
  }

  Widget _buildRow(int offset, int count) {
    final List<Widget> items = [];
    for (int i = 0; i < count; i++) {
      final globalIdx = offset + i;
      final isDone = globalIdx < widget.completedDays;
      final isCurrent = globalIdx == widget.completedDays;

      if (i > 0) {
        items.add(Container(
          width: 12,
          height: 1.5,
          color: isDone
              ? const Color(0x4DF59E0B)
              : const Color(0x17FFFFFF),
        ));
      }

      if (isDone) {
        items.add(_DotDone());
      } else if (isCurrent) {
        items.add(_DotCurrent(pulseAnim: _pulseAnim));
      } else {
        items.add(_DotFuture());
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items,
    );
  }
}

class _DotDone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: const Color(0x2EF59E0B),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Color(0x47F59E0B), blurRadius: 8, spreadRadius: 2),
        ],
      ),
      child: const Center(child: Text('🔥', style: TextStyle(fontSize: 11))),
    );
  }
}

class _DotCurrent extends StatelessWidget {
  final Animation<double> pulseAnim;
  const _DotCurrent({required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (_, __) => Opacity(
        opacity: pulseAnim.value,
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: const Color(0x2EFBBF24),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(245, 158, 11,
                    0.18 + 0.24 * pulseAnim.value),
                blurRadius: 4 + 10 * pulseAnim.value,
                spreadRadius: 1 + 3 * pulseAnim.value,
              ),
            ],
          ),
          child: const Center(child: Text('🔥', style: TextStyle(fontSize: 11))),
        ),
      ),
    );
  }
}

class _DotFuture extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0x1AFFFFFF), width: 1.5),
      ),
    );
  }
}

// ─── Карточка активности ──────────────────────────────────────────────────────
class _ActivityCard extends StatelessWidget {
  final int pointsToday;
  final VoidCallback onDetailsTap;

  const _ActivityCard({required this.pointsToday, required this.onDetailsTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0x0DFFFFFF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 40,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Активность за сегодня',
            style: TextStyle(fontSize: 12, color: _textSec, letterSpacing: 0.03),
          ),
          const SizedBox(height: 4),
          Text(
            '$pointsToday',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: _textPri,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onDetailsTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
              decoration: BoxDecoration(
                color: _goldBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _goldBorder),
                boxShadow: const [
                  BoxShadow(color: Color(0x2ED3A26D), blurRadius: 8, spreadRadius: 1),
                ],
              ),
              child: const Text(
                'Подробнее',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _gold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Список привычек ──────────────────────────────────────────────────────────
class _HabitList extends StatelessWidget {
  final List<dynamic> habits;
  final HabitsNotifier habitsNotifier;
  final ScoringNotifier scoringNotifier;

  const _HabitList({
    required this.habits,
    required this.habitsNotifier,
    required this.scoringNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: habits.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final habit = habits[i];
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
    );
  }
}

// ─── Пустое состояние ─────────────────────────────────────────────────────────
class _EmptyHabits extends StatelessWidget {
  final VoidCallback onAddTap;
  const _EmptyHabits({required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Нет выбранных привычек.',
            style: TextStyle(fontSize: 13, color: _textDis, height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Нажмите + чтобы добавить',
            style: TextStyle(fontSize: 13, color: _textDis, height: 1.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── FAB «+» ─────────────────────────────────────────────────────────────────
class _FabAdd extends StatelessWidget {
  final VoidCallback onTap;
  const _FabAdd({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _goldBg,
            shape: BoxShape.circle,
            border: Border.all(color: _goldBorder),
            boxShadow: const [
              BoxShadow(
                color: Color(0x4DD3A26D),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '+',
              style: TextStyle(
                fontSize: 24,
                color: _gold,
                fontWeight: FontWeight.w300,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Боттом-шит «Подробнее» ───────────────────────────────────────────────────
class _DetailSheet extends StatelessWidget {
  final Map<String, int> habitClicksToday;
  final List<dynamic> habits;

  const _DetailSheet({
    required this.habitClicksToday,
    required this.habits,
  });

  @override
  Widget build(BuildContext context) {
    // Фильтруем только привычки с кликами сегодня
    final activeEntries = habitClicksToday.entries
        .where((e) => e.value > 0)
        .map((e) {
      final matches = habits.where((h) => h.id == e.key);
      if (matches.isEmpty) return null;
      return (habit: matches.first, clicks: e.value);
    })
        .whereType<dynamic>()
        .toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 3,
            decoration: BoxDecoration(
              color: const Color(0x26FFFFFF),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'АКТИВНОСТЬ ЗА СЕГОДНЯ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _textDis,
                letterSpacing: 0.07,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (activeEntries.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Сегодня действий не было.',
                style: TextStyle(fontSize: 13, color: _textSec),
              ),
            )
          else
            ...activeEntries.map((entry) {
              final total = entry.habit.scoreValue * entry.clicks;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.habit.title,
                          style: const TextStyle(fontSize: 14, color: _textPri),
                        ),
                        Text(
                          '× ${entry.clicks}  ·  −$total XP',
                          style: const TextStyle(fontSize: 12, color: _textSec),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0x0DFFFFFF), height: 1),
                ],
              );
            }),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0x0AFFFFFF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x0DFFFFFF)),
              ),
              child: const Center(
                child: Text(
                  'Свернуть',
                  style: TextStyle(fontSize: 13, color: _textSec),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── DopamineHoldButton (без изменений логики) ────────────────────────────────
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
  double _lastProgress = 0;

  Duration get _holdDuration {
    if (widget.points <= 3) return const Duration(milliseconds: 400);
    if (widget.points <= 7) return const Duration(milliseconds: 800);
    return const Duration(milliseconds: 1200);
  }

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: _holdDuration);
    _animationController.addListener(_onProgressChanged);
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) _triggerSuccess();
    });
  }

  void _onProgressChanged() {
    final current = _animationController.value;
    if (current > _lastProgress) {
      final step = (current * 10).floor();
      if (step % 2 == 0) HapticService.impact(widget.points);
    }
    _lastProgress = current;
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
    HapticService.impact(widget.points);
    _animationController.reset();
    widget.onTriggered();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.isLoading) return;
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails _) {
    if (_animationController.status != AnimationStatus.completed)
      _animationController.reverse();
  }

  void _onTapCancel() {
    if (_animationController.status != AnimationStatus.completed)
      _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Stack(
        children: [
          // Фон кнопки
          Container(
            height: 58,
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0x0DFFFFFF)),
            ),
          ),
          // Заливка прогресса
          AnimatedBuilder(
            animation: _animationController,
            builder: (_, __) => FractionallySizedBox(
              widthFactor: _animationController.value,
              child: Container(
                height: 58,
                decoration: BoxDecoration(
                  color: widget.points >= 8
                      ? const Color(0x40D3A26D)
                      : const Color(0x268EB897),
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
          ),
          // Контент
          SizedBox(
            height: 58,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _textPri,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (widget.isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _gold,
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: _goldBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _goldBorder),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x2ED3A26D),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Text(
                        '${widget.points}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _gold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Иконка профиля (без зависимости от пакета иконок) ───────────────────────
class _UserIcon {
  static const person = IconData(0xe7fd, fontFamily: 'MaterialIcons');
}