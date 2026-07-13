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

class _StreakPopupDialog extends StatelessWidget {
  final StreakState state;
  final VoidCallback onDismiss;

  const _StreakPopupDialog({required this.state, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final displayCase = state.displayCase;
    final pct = ((state.record!.currentMultiplier - 1.0) * 100).round();
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

    final title = titles[displayCase]![idx];
    final body = bodies[displayCase]![idx];
    final button = buttons[displayCase]!;

    return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.35),
                blurRadius: 24,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                blurRadius: 48,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(body, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: onDismiss, child: Text(button)),
          ],
        ),
      ),
     ),
    );
  }
}