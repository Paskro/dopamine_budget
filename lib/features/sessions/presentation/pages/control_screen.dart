import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dopamine_budget/features/sessions/presentation/state/control_screen_notifier.dart';

// lib/features/sessions/presentation/pages/control_screen.dart

class ControlScreen extends StatelessWidget {
  final ControlScreenNotifier controlNotifier;

  const ControlScreen({
    Key? key,
    required this.controlNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controlNotifier.checkAndResetDayIfNeeded();
    return ListenableBuilder(
      listenable: controlNotifier,
      builder: (context, _) {
        final state = controlNotifier.state;

        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Контроль')),
          body: state.status == ControlScreenStatus.brokenLocked
              ? _BrokenLockedScreen()
              : _ActiveScreen(controlNotifier: controlNotifier, state: state),
        );
      },
    );
  }
}

class _ActiveScreen extends StatelessWidget {
  final ControlScreenNotifier controlNotifier;
  final ControlScreenState state;

  const _ActiveScreen({
    required this.controlNotifier,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habits = state.sessionHabits;


    final hasUnaffordableHabit =
        habits.any((h) => state.balance < h.scoreValue);

    final showBrokenButton = state.balance <= 0 || hasUnaffordableHabit;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FuelTankCard(balance: state.balance, dailyLimit: state.dailyLimit),
          const SizedBox(height: 24),

          Text(
            'Зафиксировать действие',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: habits.isEmpty
                ? Center(
                    child: Text(
                      'Нет привязанных привычек.',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    itemCount: habits.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      final canAfford = state.balance >= habit.scoreValue;

                      return Opacity(
                        opacity: canAfford ? 1.0 : 0.4,
                        child: IgnorePointer(
                          ignoring: !canAfford,
                          child: ControlHabitButton(
                            title: habit.title,
                            points: habit.scoreValue,
                            onTriggered: () async {
                              await controlNotifier.logHabitClick(
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

          if (showBrokenButton) ...[
            const SizedBox(height: 16),
            _BrokenHoldButton(
              onConfirmed: () => controlNotifier.confirmBreak(),
            ),
          ],
        ],
      ),
    );
  }
}

class _BrokenLockedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.6),
          ),
          const SizedBox(height: 32),
          Text(
            'Спасибо. Этот день зафиксирован.',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'Ты нажал кнопку, а значит — проявил осознанность и признал срыв. '
            'Мозг сейчас ищет лёгкий дофамин, и это биохимия, а не твоя слабость. '
            'Интерфейс контроля на сегодня закрыт, чтобы снизить напряжение от подсчётов.\n\n'
            'Мы не ругаем. Отдохни от контроля. '
            'Твой полный бензобак и новый шанс будут ждать тебя завтра утром. Увидимся.',
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: theme.colorScheme.onSurface.withOpacity(0.75),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FuelTankCard extends StatelessWidget {
  final int balance;
  final int dailyLimit;

  const _FuelTankCard({required this.balance, required this.dailyLimit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fillRatio =
        dailyLimit > 0 ? (balance / dailyLimit).clamp(0.0, 1.0) : 0.0;

    final tankColor = fillRatio > 0.5
        ? Colors.green.shade600
        : fillRatio > 0.2
            ? Colors.orange.shade600
            : Colors.red.shade600;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Бензобак',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: fillRatio,
                minHeight: 16,
                backgroundColor:
                    theme.colorScheme.onPrimaryContainer.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(tankColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$balance / $dailyLimit XP',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: tankColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ControlHabitButton extends StatefulWidget {
  final String title;
  final int points;
  final VoidCallback onTriggered;

  const ControlHabitButton({
    Key? key,
    required this.title,
    required this.points,
    required this.onTriggered,
  }) : super(key: key);

  @override
  State<ControlHabitButton> createState() => _ControlHabitButtonState();
}

class _ControlHabitButtonState extends State<ControlHabitButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  Duration get _holdDuration {
    if (widget.points <= 3) return const Duration(milliseconds: 600);
    if (widget.points <= 7) return const Duration(milliseconds: 1300);
    return const Duration(milliseconds: 2200);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _holdDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _onSuccess();
      });
  }

  @override
  void didUpdateWidget(covariant ControlHabitButton old) {
    super.didUpdateWidget(old);
    if (old.points != widget.points) _controller.duration = _holdDuration;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSuccess() {
    widget.points <= 3
        ? HapticFeedback.lightImpact()
        : widget.points <= 7
            ? HapticFeedback.mediumImpact()
            : HapticFeedback.vibrate();
    _controller.reset();
    widget.onTriggered();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        if (_controller.status != AnimationStatus.completed) {
          _controller.reverse();
        }
      },
      onTapCancel: () {
        if (_controller.status != AnimationStatus.completed) {
          _controller.reverse();
        }
      },
      child: Stack(
        children: [
          Container(
            height: 62,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.15)),
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => FractionallySizedBox(
              widthFactor: _controller.value,
              child: Container(
                height: 62,
                decoration: BoxDecoration(
                  color: widget.points >= 8
                      ? Colors.redAccent.withOpacity(0.25)
                      : theme.colorScheme.primary.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
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
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
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

class _BrokenHoldButton extends StatefulWidget {
  final VoidCallback onConfirmed;
  const _BrokenHoldButton({required this.onConfirmed});

  @override
  State<_BrokenHoldButton> createState() => _BrokenHoldButtonState();
}

class _BrokenHoldButtonState extends State<_BrokenHoldButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const Duration _holdDuration = Duration(milliseconds: 2500);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _holdDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _onConfirmed();
      })
      ..addListener(_onProgressChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onProgressChanged() {
    final p = _controller.value;
    if (p <= 0) return;

    double intensity;
    if (p <= 0.15) {
      intensity = 0.20 + (p / 0.15) * 0.60;
    } else if (p <= 0.85) {
      final t = (p - 0.15) / 0.70;
      intensity = 0.80 * (1 - t * t);
    } else {
      intensity = 0.06;
    }

    final step = (_controller.value * 12).floor();
    if (step % 2 == 0 && intensity > 0.3) {
      HapticFeedback.selectionClick();
    }
  }

  void _onConfirmed() {
    HapticFeedback.heavyImpact();
    _controller.reset();
    widget.onConfirmed();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        if (_controller.status != AnimationStatus.completed) {
          _controller.reverse();
        }
      },
      onTapCancel: () {
        if (_controller.status != AnimationStatus.completed) {
          _controller.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          final progress = _controller.value;
          return Stack(
            children: [
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.shade200),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15 + progress * 0.25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              Container(
                height: 56,
                alignment: Alignment.center,
                child: Text(
                  progress > 0 ? 'Удерживай...' : 'Я сорвался',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w600,
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