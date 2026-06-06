import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dopamine_budget/core/utils/time_provider.dart';
import 'package:dopamine_budget/features/scoring/presentation/state/scoring_notifier.dart';
import 'package:dopamine_budget/features/habits/presentation/state/habits_notifier.dart';
import '../../../habits/presentation/pages/habit_management_page.dart';
import '../../../sessions/presentation/pages/calibration_result_page.dart';

class HomePage extends StatelessWidget {
  final ScoringNotifier scoringNotifier;
  final HabitsNotifier habitsNotifier;

  const HomePage({
    Key? key,
    required this.scoringNotifier,
    required this.habitsNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 🟢 ПЕРЕХВАТ КАЛИБРОВКИ: если сессия перешла в фазу Контроля (phase == 1),
    // но пользователь ещё не ознакомился с результатами (isReviewed == false) —
    // рендерим CalibrationResultPage вместо основного экрана.
    return ListenableBuilder(
      listenable: scoringNotifier,
      builder: (context, child) {
        final currentSession = scoringNotifier.state.currentSession;

        if (currentSession != null &&
            currentSession.phase == 1 &&
            !currentSession.isReviewed) {
          return CalibrationResultPage(
            session: currentSession,
            historicalScores: scoringNotifier.state.historicalScores ?? [],
            scoringNotifier: scoringNotifier,
          );
        }

        // 🔵 СТАНДАРТНЫЙ ЭКРАН: основной интерфейс привычек и баланса
        return child!;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Дофаминовый Бюджет'),
          actions: [
            IconButton(
              icon: const Icon(Icons.playlist_add_check_rounded, size: 28),
              tooltip: 'Управление привычками',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HabitManagementPage(
                      habitsNotifier: habitsNotifier,
                      sessionId: scoringNotifier.currentSessionId,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: ListenableBuilder(
          listenable: Listenable.merge([scoringNotifier, habitsNotifier]),
          builder: (context, child) {
            // Получаем только те привычки, которые выбраны пользователем (чекнуты в сессии)
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
                  // Карточка текущего баланса (Score)
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                            // ИСПОЛЬЗУЕМ ТВOЙ СУЩЕСТВУЮЩИЙ СТEЙТ:
                            '${scoringNotifier.state.pointsSpentToday} XP',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              // Проверяем флаг превышения лимита из твоего ScoringState:
                              color: scoringNotifier.state.isOverLimit ? Colors.red.shade700 : Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Зафиксировать действие',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Динамический список осознанных кнопок-привычек
                  Expanded(
                    child: activeHabits.isEmpty
                        ? Center(
                            child: Text(
                              'Нет выбранных привычек.\nНажмите на иконку сверху, чтобы добавить.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                            ),
                          )
                        : ListView.separated(
                            itemCount: activeHabits.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final habit = activeHabits[index];

                              return DopamineHoldButton(
                                title: habit.title,        // Исправлено: используем .title вместо .name
                                points: habit.scoreValue,  // Исправлено: используем .scoreValue вместо .points

                                // [АРХИТЕКТОР]: Защита от спама на уровне UI
                                isLoading: habitsNotifier.isLoading,

                                onTriggered: () async {
                                  // 1. Пишем лог срыва в ActionsTable через UseCase внутри Notifier
                                  await habitsNotifier.addActionLog(
                                    habitId: habit.id,
                                    points: habit.scoreValue, // Исправлено: передаем .scoreValue вместо .points
                                    timestamp: TimeProvider.now,
                                  );

                                  // 2. Обновляем баланс суток (вызываем метод у твоего scoringNotifier)
                                  await scoringNotifier.refreshTodayState();
                                },
                              );
                            },
                          ),
                  ),

                  // Блок тестирования времени (из старой версии)
                  const Divider(height: 32),
                  Card(
                    color: Colors.grey.shade100,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: Column(
                        children: [
                          Text(
                            'Виртуальное время: ${TimeProvider.now.toLocal().toString().substring(0, 16)}',
                            style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.fast_forward),
                                label: const Text('+1 День'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber.shade700,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () async {
                                  TimeProvider.addDuration(const Duration(days: 1));
                                  await scoringNotifier.checkAndResetDayIfNeeded();
                                },
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade300,
                                  foregroundColor: Colors.black54,
                                ),
                                onPressed: () async {
                                  TimeProvider.reset();
                                  await scoringNotifier.refreshTodayState();
                                },
                                child: const Text('Сбросить время'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),   // Scaffold
    ); // ListenableBuilder
  }
}

/// Внутренний интерактивный виджет для удержания с прогресс-баром и haptic-откликом
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

  // Динамическая взаимосвязь времени удержания от тяжести баллов
  Duration get _holdDuration {
    if (widget.points <= 3) {
      return const Duration(milliseconds: 600);   // Легкая: "комарик" (0.6с)
    } else if (widget.points <= 7) {
      return const Duration(milliseconds: 1300);  // Средняя
    } else {
      return const Duration(milliseconds: 2200);  // Тяжелая: сильное сопротивление (2.2с)
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _holdDuration,
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _triggerSuccess();
      }
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

  // Дифференцированная вибрация в зависимости от тяжести проступка
  void _executeDifferentiatedHaptic() {
    if (widget.points <= 3) {
      HapticFeedback.lightImpact(); // Легкий быстрый отклик
    } else if (widget.points <= 7) {
      HapticFeedback.mediumImpact(); // Средний щелчок
    } else {
      HapticFeedback.vibrate(); // Тяжелая системная вибрация
    }
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.isLoading) return;
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (_animationController.status != AnimationStatus.completed) {
      _animationController.reverse(); // Отпустил раньше времени — плавный откат назад
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
          // 1. Подложка кнопки (Базовая форма)
          Container(
            height: 62,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.15),
              ),
            ),
          ),

          // 2. Наполняющийся бар внутри кнопки
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FractionallySizedBox(
                widthFactor: _animationController.value,
                child: Container(
                  height: 62,
                  decoration: BoxDecoration(
                    // Окрашиваем в красный деструктивные привычки с большим весом
                    color: widget.points >= 8
                        ? Colors.redAccent.withOpacity(0.25)
                        : theme.colorScheme.primary.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              );
            },
          ),

          // 3. Контентная часть (Текст и индикатор очков)
          Container(
            height: 62,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
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
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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