import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dopamine_budget/features/sessions/presentation/state/control_screen_notifier.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/archive_session_use_case.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/delete_session_use_case.dart';
import 'package:dopamine_budget/features/habits/presentation/state/habits_notifier.dart';
import 'package:dopamine_budget/features/sessions/presentation/pages/profile_screen.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/features/sessions/presentation/widgets/session_settings_sheet.dart';
import 'package:dopamine_budget/features/scoring/presentation/state/scoring_notifier.dart';
import 'package:dopamine_budget/core/utils/haptic_service.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/habit_click_log.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
const _bg         = Color(0xFF1A2421);
const _surface    = Color(0xFF24342F);
const _surfaceEl  = Color(0xFF2A3D37);
const _accent     = Color(0xFF8EB897); // sage green
const _gold       = Color(0xFFD3A26D); // warm clay / amber
const _terracotta = Color(0xFF6B3A2A);
const _textPri    = Color(0xFFF2EFEA);
const _textSec    = Color(0xFFA8B5AF);
const _textDis    = Color(0xFF6E7A75);

// ─── Root widget ──────────────────────────────────────────────────────────────
class ControlScreen extends StatefulWidget {
  final ControlScreenNotifier controlNotifier;
  final Session session;
  final HabitsNotifier habitsNotifier;
  final ArchiveSessionUseCase archiveSessionUseCase;
  final DeleteSessionUseCase deleteSessionUseCase;
  final SessionRepository sessionRepository;
  final ScoringNotifier scoringNotifier;

  const ControlScreen({
    Key? key,
    required this.controlNotifier,
    required this.session,
    required this.habitsNotifier,
    required this.archiveSessionUseCase,
    required this.deleteSessionUseCase,
    required this.sessionRepository,
    required this.scoringNotifier,
  }) : super(key: key);

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  StreamSubscription<String>? _errorSub;
  bool _perfectRunActive = false;
  bool _perfectRunShown = false;

  @override
  void initState() {
    super.initState();
    widget.controlNotifier.checkAndResetDayIfNeeded();
    _errorSub = widget.controlNotifier.errorEvents.listen((message) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(message, style: const TextStyle(color: _textPri)),
          backgroundColor: _surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ));
    });
  }

  @override
  void dispose() {
    _errorSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.controlNotifier.checkAndResetDayIfNeeded();
    return ListenableBuilder(
      listenable: widget.controlNotifier,
      builder: (context, _) {
        final state = widget.controlNotifier.state;

        if (state.isLoading) {
          return const Scaffold(
            backgroundColor: _bg,
            body: Center(child: CircularProgressIndicator(color: _accent)),
          );
        }

        return Scaffold(
          backgroundColor: _bg,
          body: state.status == ControlScreenStatus.brokenLocked
              ? const _BrokenLockedScreen()
              : _ActiveScreen(
            controlNotifier: widget.controlNotifier,
            state: state,
            perfectRunActive: _perfectRunActive,
            perfectRunShown: _perfectRunShown,
            onPerfectRunConfirmed: () => setState(() {
              _perfectRunActive = true;
              _perfectRunShown = true;
            }),
            onPerfectRunReverted: () => setState(() {
              _perfectRunActive = false;
            }),
            sessionRepository: widget.sessionRepository,
            deleteSessionUseCase: widget.deleteSessionUseCase,
            session: widget.session,
            habitsNotifier: widget.habitsNotifier,
            archiveSessionUseCase: widget.archiveSessionUseCase,
            scoringNotifier: widget.scoringNotifier,
          ),
        );
      },
    );
  }
}

// ─── Active screen ────────────────────────────────────────────────────────────
class _ActiveScreen extends StatefulWidget {
  final ControlScreenNotifier controlNotifier;
  final ControlScreenState state;
  final SessionRepository sessionRepository;
  final DeleteSessionUseCase deleteSessionUseCase;
  final Session session;
  final HabitsNotifier habitsNotifier;
  final ArchiveSessionUseCase archiveSessionUseCase;
  final ScoringNotifier scoringNotifier;
  final bool perfectRunActive;
  final bool perfectRunShown;
  final VoidCallback onPerfectRunConfirmed;
  final VoidCallback onPerfectRunReverted;

  const _ActiveScreen({
    required this.controlNotifier,
    required this.state,
    required this.sessionRepository,
    required this.deleteSessionUseCase,
    required this.session,
    required this.habitsNotifier,
    required this.archiveSessionUseCase,
    required this.scoringNotifier,
    required this.perfectRunActive,
    required this.perfectRunShown,
    required this.onPerfectRunConfirmed,
    required this.onPerfectRunReverted,
  });

  @override
  State<_ActiveScreen> createState() => _ActiveScreenState();
}

class _ActiveScreenState extends State<_ActiveScreen> {
  final ValueNotifier<({double progress, int cost})> _holdProgress =
  ValueNotifier((progress: 0.0, cost: 0));

  @override
  void dispose() {
    _holdProgress.dispose();
    super.dispose();
  }

  ControlScreenState get _state => widget.state;

  bool get _perfectRunActive => widget.perfectRunActive;
  bool get _perfectRunShown => widget.perfectRunShown;

  @override
  void didUpdateWidget(covariant _ActiveScreen old) {
    super.didUpdateWidget(old);
    if (_perfectRunActive && widget.state.hasHabitClickToday) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onPerfectRunReverted();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final habits = _state.sessionHabits;
    final hasUnaffordable = habits.any((h) => _state.balance < h.scoreValue);
    final showStop = habits.isNotEmpty &&
        (_state.balance <= 0 || hasUnaffordable);
    final showPerfect = _state.canShowGoodBoyButton && !_perfectRunShown;
    debugPrint('[PERFECT] dayStatus=${_state.dayStatus} hasClickToday=${_state.hasHabitClickToday} canShow=${_state.canShowGoodBoyButton} shown=$_perfectRunShown showPerfect=$showPerfect');
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      color: _perfectRunActive
          ? const Color(0xFF0D3320)  // насыщеннее — заметнее
          : _bg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(
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
              onSettingsTap: () => SessionSettingsSheet.show(
                context: context,
                session: widget.session,
                habitsNotifier: widget.habitsNotifier,
                scoringNotifier: widget.scoringNotifier,
              ),
            ),

            const SizedBox(height: 8),

            _GaugeSection(
              balance: _state.balance,
              dailyLimit: _state.dailyLimit,
              perfectRunActive: _perfectRunActive,
              holdProgress: _holdProgress,
              onDetailsTap: () => _showDetailsSheet(context, _state),
            ),

            const SizedBox(height: 4),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Ваши привычки',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _textPri,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: habits.isEmpty
                  ? Center(
                child: Text(
                  'Нет привязанных привычек.',
                  style: const TextStyle(color: _textDis, fontSize: 15),
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: habits.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final habit = habits[i];
                  final canAfford = _state.balance >= habit.scoreValue;
                  return Opacity(
                    opacity: canAfford ? 1.0 : 0.38,
                    child: IgnorePointer(
                      ignoring: !canAfford,
                      child:ControlHabitButton(
                        title: habit.title,
                        points: habit.scoreValue,
                        holdProgress: _holdProgress,
                        onTriggered: () async {
                          await widget.controlNotifier.logHabitClick(
                            habitId: habit.id,
                            scoreCost: habit.scoreValue,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            if (showStop)
              _BottomRoundButton.stop(
                onConfirmed: () => widget.controlNotifier.confirmBreak(),
              ),

            if (showPerfect && !showStop)
              _BottomRoundButton.perfect(
                onConfirmed: widget.onPerfectRunConfirmed,
                onRealConfirm: () => widget.controlNotifier.confirmGoodBoy(),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showDetailsSheet(BuildContext context, ControlScreenState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _DetailsSheet(
        logs: state.todayLogs,
        balance: state.balance,
        dailyLimit: state.dailyLimit,
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onSettingsTap;

  const _Header({required this.onProfileTap, required this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            'Self-control',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _textPri,
              letterSpacing: 0.2,
            ),
          ),
          Positioned(
            right: 0,
            child: Row(
              children: [
                _IconBtn(icon: LucideIcons.tent, onTap: onProfileTap),
                const SizedBox(width: 10),
                _IconBtn(icon: LucideIcons.leaf, onTap: onSettingsTap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Icon(icon, size: 17, color: _textSec),
      ),
    );
  }
}

// ─── Gauge ────────────────────────────────────────────────────────────────────
class _GaugeSection extends StatelessWidget {
  final int balance;
  final int dailyLimit;
  final bool perfectRunActive;
  final ValueNotifier<({double progress, int cost})> holdProgress;
  final VoidCallback onDetailsTap;

  const _GaugeSection({
    required this.balance,
    required this.dailyLimit,
    required this.perfectRunActive,
    required this.holdProgress,
    required this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 280,
          height: 148,
          child: ValueListenableBuilder<({double progress, int cost})>(
            valueListenable: holdProgress,
            builder: (_, val, __) => CustomPaint(
              painter: _GaugePainter(
                balance: balance,
                dailyLimit: dailyLimit,
                previewBalance: balance - (val.cost * val.progress).round(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$balance',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: _needleColor(balance, dailyLimit),
                ),
              ),
              TextSpan(
                text: '  из $dailyLimit',
                style: const TextStyle(
                  fontSize: 14,
                  color: _textDis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onDetailsTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: const Text(
              'Подробнее',
              style: TextStyle(fontSize: 13, color: _textSec),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  static Color _needleColor(int balance, int limit) {
    if (limit == 0) return _textDis;
    final ratio = balance / limit;
    if (ratio > 0.66) return _accent;       // full → sage
    if (ratio > 0.33) return _textPri;      // mid  → white
    return _gold;                            // low  → amber
  }
}

class _GaugePainter extends CustomPainter {
  final int balance;
  final int dailyLimit;
  final int previewBalance;

  _GaugePainter({
    required this.balance,
    required this.dailyLimit,
    int? previewBalance,
  }) : previewBalance = previewBalance ?? balance;

  static const double _startDeg = 215;
  static const double _spanDeg  = 110;
  static const double _cx = 140;
  static const double _cy = 130;
  static const double _r  = 96;

  double get _ratio => dailyLimit > 0
      ? (previewBalance / dailyLimit).clamp(0.0, 1.0)
      : 0.0;

  Color get _fillColor {
    if (_ratio > 0.66) return _accent;
    if (_ratio > 0.33) return _textPri;
    return _gold;
  }

  Offset _ptOnArc(double deg) {
    final rad = deg * pi / 180;
    return Offset(_cx + _r * cos(rad), _cy + _r * sin(rad));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final trackPaint = Paint()
      ..color = const Color(0xFF2A3D37)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = _fillColor.withOpacity(0.55)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final needlePaint = Paint()
      ..color = _fillColor
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromCircle(center: const Offset(_cx, _cy), radius: _r);

    // Track
    canvas.drawArc(
      rect,
      _startDeg * pi / 180,
      _spanDeg * pi / 180,
      false,
      trackPaint,
    );

    // Fill
    if (_ratio > 0.001) {
      canvas.drawArc(
        rect,
        _startDeg * pi / 180,
        _spanDeg * _ratio * pi / 180,
        false,
        fillPaint,
      );
    }

    // Tick marks
    for (int i = 0; i <= 4; i++) {
      final t = i / 4.0;
      final deg = _startDeg + _spanDeg * t;
      final rad = deg * pi / 180;
      final major = i == 0 || i == 2 || i == 4;
      final inner = _r - 9.0;
      final outer = _r + 1.0;
      final p1 = Offset(_cx + inner * cos(rad), _cy + inner * sin(rad));
      final p2 = Offset(_cx + outer * cos(rad), _cy + outer * sin(rad));
      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = major
              ? const Color(0xFF6E7A75)
              : const Color(0xFF3A4D47)
          ..strokeWidth = major ? 2.0 : 1.5
          ..strokeCap = StrokeCap.round,
      );
    }

    // Labels E / 1/2 / F
    const labels = ['E', '1/2', 'F'];
    const labelTs = [0.0, 0.5, 1.0];
    final labelR = _r + 17.0;
    for (int i = 0; i < 3; i++) {
      final deg = _startDeg + _spanDeg * labelTs[i];
      final rad = deg * pi / 180;
      final pos = Offset(_cx + labelR * cos(rad), _cy + labelR * sin(rad));
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            fontSize: 11,
            color: _textDis,
            fontWeight: FontWeight.w400,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }

    // Needle
    const needleLen = 76.0;
    final needleDeg = _startDeg + _spanDeg * _ratio;
    final needleRad = needleDeg * pi / 180;
    final needleEnd = Offset(
      _cx + needleLen * cos(needleRad),
      _cy + needleLen * sin(needleRad),
    );

    // Glow
    canvas.drawLine(
      const Offset(_cx, _cy),
      needleEnd,
      Paint()
        ..color = _fillColor.withOpacity(0.25)
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawLine(
      const Offset(_cx, _cy),
      needleEnd,
      needlePaint,
    );

    // Pivot
    canvas.drawCircle(
      const Offset(_cx, _cy),
      9,
      Paint()..color = _surfaceEl,
    );
    canvas.drawCircle(
      const Offset(_cx, _cy),
      9,
      Paint()
        ..color = Colors.white.withOpacity(0.07)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.drawCircle(
      const Offset(_cx, _cy),
      5,
      Paint()..color = _fillColor,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.balance != balance ||
          old.dailyLimit != dailyLimit ||
          old.previewBalance != previewBalance;
}

// ─── Habit button (hold-to-confirm) ──────────────────────────────────────────
class ControlHabitButton extends StatefulWidget {
  final String title;
  final int points;
  final VoidCallback onTriggered;
  final ValueNotifier<({double progress, int cost})>? holdProgress;

  const ControlHabitButton({
    Key? key,
    required this.title,
    required this.points,
    required this.onTriggered,
    this.holdProgress,
  }) : super(key: key);

  @override
  State<ControlHabitButton> createState() => _ControlHabitButtonState();
}

class _ControlHabitButtonState extends State<ControlHabitButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  Duration get _holdDuration {
    if (widget.points <= 3) return const Duration(milliseconds: 400);
    if (widget.points <= 7) return const Duration(milliseconds: 800);
    return const Duration(milliseconds: 1200);
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _holdDuration)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _onSuccess();
      })
      ..addListener(_onProgressTick);
  }

  void _onProgressTick() {
    widget.holdProgress?.value = (progress: _ctrl.value, cost: widget.points);
    // Вибрация каждые 20% прогресса
    final step = (_ctrl.value * 20).floor();
    if (step != _lastStep) {
      _lastStep = step;
      HapticService.impact(widget.points);
    }
    if (_ctrl.status == AnimationStatus.reverse) return;
  }

  int _lastStep = -1;

  @override
  void didUpdateWidget(covariant ControlHabitButton old) {
    super.didUpdateWidget(old);
    if (old.points != widget.points) _ctrl.duration = _holdDuration;
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onProgressTick);
    _ctrl.dispose();
    super.dispose();
  }

  void _onSuccess() {
    HapticService.impact(widget.points);
    _lastStep = -1;
    widget.holdProgress?.value = (progress: 0.0, cost: 0);
    _ctrl.reset();
    widget.onTriggered();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        if (_ctrl.status != AnimationStatus.completed) {
          _lastStep = -1;
          widget.holdProgress?.value = (progress: 0.0, cost: 0);
          _ctrl.reverse();
        }
      },
      onTapCancel: () {
        if (_ctrl.status != AnimationStatus.completed) {
          _lastStep = -1;
          widget.holdProgress?.value = (progress: 0.0, cost: 0);
          _ctrl.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Stack(
          children: [
            Container(
              height: 58,
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
            ),
            FractionallySizedBox(
              widthFactor: _ctrl.value,
              child: Container(
                height: 58,
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            SizedBox(
              height: 58,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 16,
                          color: _textPri,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 5),
                      decoration: BoxDecoration(
                        color: _gold.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(10),
                        border:
                        Border.all(color: _gold.withOpacity(0.22)),
                      ),
                      child: Text(
                        '-${widget.points}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
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
      ),
    );
  }
}

// ─── Bottom round button (Stop Control / Perfect Run) ─────────────────────────
class _BottomRoundButton extends StatefulWidget {
  final bool isPerfect;
  final VoidCallback onConfirmed;
  final VoidCallback? onRealConfirm;

  const _BottomRoundButton._({
    required this.isPerfect,
    required this.onConfirmed,
    this.onRealConfirm,
  });

  factory _BottomRoundButton.stop({required VoidCallback onConfirmed}) =>
      _BottomRoundButton._(
          isPerfect: false, onConfirmed: onConfirmed);

  factory _BottomRoundButton.perfect({
    required VoidCallback onConfirmed,
    required VoidCallback onRealConfirm,
  }) =>
      _BottomRoundButton._(
          isPerfect: true,
          onConfirmed: onConfirmed,
          onRealConfirm: onRealConfirm);

  @override
  State<_BottomRoundButton> createState() => _BottomRoundButtonState();
}

class _BottomRoundButtonState extends State<_BottomRoundButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  static const _holdDuration = Duration(milliseconds: 2500);
  bool _overlayPushed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _holdDuration)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _onConfirmed();
      })
      ..addListener(_onProgressTick);
  }

  void _onProgressTick() {
    final p = _ctrl.value;
    if (p <= 0) { _lastStep = -1; return; }

    // Не вибрировать при реверсе
    if (_ctrl.status == AnimationStatus.reverse) return;

    double intensity;
    if (p <= 0.15) {
      intensity = 0.20 + (p / 0.15) * 0.60;
    } else if (p <= 0.85) {
      final t = (p - 0.15) / 0.70;
      intensity = 0.80 * (1 - t * t);
    } else {
      intensity = 0.06;
    }
    final step = (p * 12).floor();
    if (step != _lastStep) {
      _lastStep = step;
      if (intensity > 0.3) HapticService.selection();
    }
  }

  int _lastStep = -1;

  @override
  void dispose() {
    _ctrl.removeListener(_onProgressTick);
    _ctrl.dispose();
    super.dispose();
  }

  void _onConfirmed() {
    debugPrint('[PERFECT] _onConfirmed called isPerfect=${widget.isPerfect}');
    HapticService.heavy();
    _ctrl.reset();
    if (widget.isPerfect) {
      widget.onRealConfirm?.call();
      _showKptFlash();
    }
    widget.onConfirmed();
  }

  void _showKptFlash() {
    if (!mounted) return;
    _overlayPushed = true;
    final nav = Navigator.of(context, rootNavigator: true);
    nav.push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (_, __, ___) => const _PerfectRunCelebrationOverlay(),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (nav.canPop()) nav.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color btnColor =
    widget.isPerfect ? const Color(0xFF8B6914) : _terracotta;
    final Color iconColor =
    widget.isPerfect ? const Color(0xFF1A2421) : _textPri;
    final String label = widget.isPerfect ? 'Perfect' : 'Stop';
    final IconData icon =
    widget.isPerfect ? LucideIcons.star : LucideIcons.xSquare;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Center(
        child: GestureDetector(
          onTapDown: (_) => _ctrl.forward(),
          onTapUp: (_) {
            if (_ctrl.status != AnimationStatus.completed) _ctrl.reverse();
          },
          onTapCancel: () {
            if (_ctrl.status != AnimationStatus.completed) _ctrl.reverse();
          },
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) {
              final progress = _ctrl.value;
              final deg = progress * 360;
              return SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Progress ring
                    CustomPaint(
                      size: const Size(80, 80),
                      painter: _RingPainter(
                        progress: progress,
                        color: Colors.white.withOpacity(0.28),
                        radius: 38,
                        strokeWidth: 3,
                      ),
                    ),
                    // Button body
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: btnColor,
                        shape: BoxShape.circle,
                        boxShadow: widget.isPerfect
                            ? [
                          BoxShadow(
                            color: const Color(0xFFC49A20)
                                .withOpacity(0.35),
                            blurRadius: 24,
                            spreadRadius: 0,
                          ),
                        ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icon, size: 26, color: iconColor),
                          const SizedBox(height: 2),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                              color: iconColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double radius;
  final double strokeWidth;

  const _RingPainter({
    required this.progress,
    required this.color,
    required this.radius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}

// ─── Details bottom sheet ──────────────────────────────────────────────────────
class _DetailsSheet extends StatelessWidget {
  final List<HabitClickLog> logs;
  final int balance;
  final int dailyLimit;

  const _DetailsSheet({
    required this.logs,
    required this.balance,
    required this.dailyLimit,
  });

  @override
  Widget build(BuildContext context) {
    // Группировка: habitTitle → {count, totalCost}
    final grouped = <String, ({int count, int total})>{};
    for (final log in logs) {
      final prev = grouped[log.habitTitle];
      grouped[log.habitTitle] = (
      count: (prev?.count ?? 0) + 1,
      total: (prev?.total ?? 0) + log.scoreCost,
      );
    }
    final entries = grouped.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.count.compareTo(a.value.count);
        if (byCount != 0) return byCount;
        return b.value.total.compareTo(a.value.total);
      });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 4,
          margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 14, 24, 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Сегодня',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _textPri,
              ),
            ),
          ),
        ),
        const Divider(height: 1, color: Color(0x0FFFFFFF)),
        if (entries.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Text(
              'Сегодня привычек не зафиксировано.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: _textDis),
            ),
          )
        else
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: entries.length,
              separatorBuilder: (_, __) =>
              const Divider(height: 1, color: Color(0x0FFFFFFF)),
              itemBuilder: (_, i) {
                final title = entries[i].key;
                final data = entries[i].value;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                              fontSize: 15, color: _textPri),
                        ),
                      ),
                      Text(
                        '${data.count}× · −${data.total}',
                        style: const TextStyle(
                            fontSize: 14, color: _textSec),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
      ],
    );
  }
}

// ─── Broken locked screen ─────────────────────────────────────────────────────
class _BrokenLockedScreen extends StatelessWidget {
  const _BrokenLockedScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                LucideIcons.leaf,
                size: 56,
                color: _accent.withOpacity(0.6),
              ),
              const SizedBox(height: 32),
              const Text(
                'Спасибо. Этот день зафиксирован.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _textPri,
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Ты нажал кнопку, а значит — проявил осознанность и признал срыв. '
                    'Мозг сейчас ищет лёгкий дофамин, и это биохимия, а не твоя слабость. '
                    'Интерфейс контроля на сегодня закрыт, чтобы снизить напряжение от подсчётов.\n\n'
                    'Мы не ругаем. Отдохни от контроля. '
                    'Твой полный бензобак и новый шанс будут ждать тебя завтра утром. Увидимся.',
                style: TextStyle(
                  fontSize: 15,
                  color: _textSec,
                  height: 1.65,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

  // ─── Perfect Run Celebration Overlay ─────────────────────────────────────────
  class _PerfectRunCelebrationOverlay extends StatefulWidget {
  const _PerfectRunCelebrationOverlay();

  @override
  State<_PerfectRunCelebrationOverlay> createState() =>
  _PerfectRunCelebrationOverlayState();
  }

  class _PerfectRunCelebrationOverlayState
  extends State<_PerfectRunCelebrationOverlay>
  with TickerProviderStateMixin {
  late AnimationController _flashCtrl;
  late AnimationController _particleCtrl;
  late AnimationController _textCtrl;
  late Animation<double> _flashAnim;
  late Animation<double> _textAnim;

  final List<_Particle> _particles = [];
  final _rng = Random();

  static const _colors = [
  Color(0xFFD3A26D),
  Color(0xFFC49A20),
  Color(0xFF8EB897),
  Color(0xFFF2EFEA),
  Color(0xFFE8C97A),
  Color(0xFF6FCF97),
  ];

  @override
  void initState() {
  super.initState();

  _flashCtrl = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 500),
  );
  _flashAnim = CurvedAnimation(parent: _flashCtrl, curve: Curves.easeOut);

  _particleCtrl = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 2800),
  );

  _textCtrl = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 700),
  );
  _textAnim = CurvedAnimation(parent: _textCtrl, curve: Curves.elasticOut);

  for (int i = 0; i < 70; i++) {
  _particles.add(_Particle(
  x: _rng.nextDouble(),
  y: _rng.nextDouble() * 0.3 + 0.5,
  vx: (_rng.nextDouble() - 0.5) * 2.4,
  vy: -(_rng.nextDouble() * 2.8 + 1.2),
  color: _colors[_rng.nextInt(_colors.length)],
  size: _rng.nextDouble() * 9 + 4,
  rotation: _rng.nextDouble() * pi * 2,
  rotationSpeed: (_rng.nextDouble() - 0.5) * 10,
  shape: _rng.nextInt(3),
  ));
  }

  _flashCtrl.forward();
  Future.delayed(const Duration(milliseconds: 100), () {
  if (mounted) {
  _particleCtrl.forward();
  _textCtrl.forward();
  }
  });
  Future.delayed(const Duration(milliseconds: 1800), () {
  if (mounted) _flashCtrl.reverse();
  });
  }

  @override
  void dispose() {
  _flashCtrl.dispose();
  _particleCtrl.dispose();
  _textCtrl.dispose();
  super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  return Material(
  color: Colors.transparent,
  child: AnimatedBuilder(
  animation: Listenable.merge([_flashCtrl, _particleCtrl, _textCtrl]),
  builder: (_, __) {
  return Stack(
  children: [
  // Тёмная вспышка-оверлей
  Positioned.fill(
  child: Opacity(
  opacity: _flashAnim.value * 0.85,
  child: Container(color: const Color(0xFF061A0E)),
  ),
  ),

  // Конфетти
  Positioned.fill(
  child: CustomPaint(
  painter: _ParticlePainter(
  particles: _particles,
  progress: _particleCtrl.value,
  ),
  ),
  ),

  // Текст по центру
  Center(
  child: Transform.scale(
  scale: _textAnim.value,
  child: Opacity(
  opacity: _textCtrl.value.clamp(0.0, 1.0),
  child: const Column(
  mainAxisSize: MainAxisSize.min,
  children: [
  Text(
  '✦',
  style: TextStyle(
  fontSize: 52,
  color: Color(0xFFD3A26D),
  decoration: TextDecoration.none,
  ),
  ),
  SizedBox(height: 20),
  Text(
  'Идеальный день.',
  textAlign: TextAlign.center,
  style: TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.w700,
  color: Color(0xFFF2EFEA),
  decoration: TextDecoration.none,
  height: 1.3,
  ),
  ),
  SizedBox(height: 10),
  Text(
  'Твоя воля сильнее алгоритмов',
  textAlign: TextAlign.center,
  style: TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: Color(0xFFC49A20),
  decoration: TextDecoration.none,
  height: 1.55,
  ),
  ),
  ],
  ),
  ),
  ),
  ),
  ],
  );
  },
  ),
  );
  }
  }

  class _Particle {
  final double x;
  final double y;
  final double vx;
  final double vy;
  final Color color;
  final double size;
  final double rotation;
  final double rotationSpeed;
  final int shape;

  const _Particle({
  required this.x,
  required this.y,
  required this.vx,
  required this.vy,
  required this.color,
  required this.size,
  required this.rotation,
  required this.rotationSpeed,
  required this.shape,
  });
  }

  class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  const _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
  for (final p in particles) {
  final gravity = progress * progress * 3.2;
  final cx = (p.x + p.vx * progress) * size.width;
  final cy = (p.y + p.vy * progress + gravity) * size.height;
  final fade = (1.0 - progress * 0.85).clamp(0.0, 1.0);
  final rot = p.rotation + p.rotationSpeed * progress;

  final paint = Paint()
  ..color = p.color.withOpacity(fade)
  ..style = PaintingStyle.fill;

  canvas.save();
  canvas.translate(cx, cy);
  canvas.rotate(rot);

  switch (p.shape) {
  case 0:
  canvas.drawRect(
  Rect.fromCenter(
  center: Offset.zero, width: p.size, height: p.size * 0.5),
  paint,
  );
  break;
  case 1:
  canvas.drawCircle(Offset.zero, p.size * 0.5, paint);
  break;
  case 2:
  final path = Path()
  ..moveTo(0, -p.size * 0.6)
  ..lineTo(p.size * 0.5, p.size * 0.4)
  ..lineTo(-p.size * 0.5, p.size * 0.4)
  ..close();
  canvas.drawPath(path, paint);
  break;
  }

  canvas.restore();
  }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
  }
