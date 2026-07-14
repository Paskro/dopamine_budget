import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dopamine_budget/features/streak/presentation/state/streak_notifier.dart';
import 'package:dopamine_budget/features/streak/presentation/state/streak_state.dart';

class StreakPopup extends StatelessWidget {
  final StreakNotifier notifier;

  const StreakPopup({super.key, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: notifier,
      builder: (context, _) {
        final state = notifier.state;

        if (state.isLoading ||
            state.record == null ||
            state.record!.isViewed ||
            state.displayCase == StreakDisplayCase.silence) {
          return const SizedBox.shrink();
        }

        return _StreakPopupDialog(
          state: state,
          onDismiss: () => notifier.markViewed(),
        );
      },
    );
  }
}

class _StreakPopupDialog extends StatefulWidget {
  final StreakState state;
  final VoidCallback onDismiss;

  const _StreakPopupDialog({required this.state, required this.onDismiss});

  @override
  State<_StreakPopupDialog> createState() => _StreakPopupDialogState();
}

class _StreakPopupDialogState extends State<_StreakPopupDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnim;
  late String _title;
  late String _body;
  late String _button;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    final displayCase = widget.state.displayCase;
    final pct = ((widget.state.record!.currentMultiplier - 1.0) * 100).round();
    final idx = Random().nextInt(3);

    const titles = {
      StreakDisplayCase.growth: ['Отличный старт!', 'Ты в деле!', 'Набираем обороты!'],
      StreakDisplayCase.peak: ['Потрясающе!', 'Ты мастер дисциплины.', 'Горжусь твоим постоянством!'],
      StreakDisplayCase.decay: ['Один пропуск — не беда.', 'Ничего страшного,', 'Бонус чуть уменьшился,'],
      StreakDisplayCase.neutral: ['Бонус растаял,', 'Главное не цифры,', 'Два дня без действий..'],
    };

    final bodies = {
      StreakDisplayCase.growth: ['К твоему бонусу добавилось +$pct%.', 'Твой множитель растет: +$pct%.', 'Твой бонус теперь +$pct%.'],
      StreakDisplayCase.peak: ['Ты на пике формы — бонус +20%.', 'Максимальный бонус 20% твой!', 'Максимум +20% к осознанности.'],
      StreakDisplayCase.decay: ['Возвращайся в ритм! Бонус: $pct%.', 'Возвращайся в ритм! Бонус: $pct%.', 'Но ты всё ещё в игре: $pct%.'],
      StreakDisplayCase.neutral: ['Но это отличный повод начать заново.', 'Давай попробуем снова?', 'Может пора вернуться?'],
    };

    const buttons = {
      StreakDisplayCase.growth: 'Круто!',
      StreakDisplayCase.peak: 'Держу планку! 💪',
      StreakDisplayCase.decay: 'Я постараюсь',
      StreakDisplayCase.neutral: 'Начинаю заново',
    };

    _title = titles[displayCase]![idx];
    _body = bodies[displayCase]![idx];
    _button = buttons[displayCase]!;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const goldLight = Color(0xFFFFD700);
    const goldDark = Color(0xFFB8860B);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _glowAnim,
        builder: (context, child) {
          final glow = _glowAnim.value;
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Color.lerp(goldDark, goldLight, glow)!,
                width: 1.5 + glow * 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: goldLight.withOpacity(0.25 + glow * 0.35),
                  blurRadius: 16 + glow * 24,
                  spreadRadius: 2 + glow * 6,
                ),
                BoxShadow(
                  color: goldDark.withOpacity(0.15 + glow * 0.15),
                  blurRadius: 40 + glow * 20,
                  spreadRadius: 4 + glow * 4,
                ),
              ],
            ),
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(_body, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: widget.onDismiss, child: Text(_button)),
            ],
          ),
        ),
      ),
    );
  }
}