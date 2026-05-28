import 'package:flutter/material.dart';
import 'package:dopamine_budget/core/utils/time_provider.dart';
import 'package:dopamine_budget/features/scoring/presentation/state/scoring_notifier.dart';
import 'package:dopamine_budget/features/scoring/presentation/state/scoring_state.dart';
import '../../../habits/presentation/state/habits_notifier.dart';

class HomePage extends StatelessWidget {
  final ScoringNotifier scoringNotifier;
  final dynamic habitsNotifier; // Добавляем поддержку habitsNotifier (пока как dynamic, чтобы не воевать с импортами)

  const HomePage({
    Key? key,
    required this.scoringNotifier,
    required this.habitsNotifier, // Делаем его обязательным, как в root_gate.dart
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dopamine Budget'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<ScoringState>(
        valueListenable: scoringNotifier,
        builder: (context, state, child) {
          // ==========================================
          // БЛОК 1: ИНДИКАТОР ЗАГРУЗКИ ДАННЫХ
          // ==========================================
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ==========================================
              // БЛОК 2: ОСНОВНОЙ МОНИТОР БЮДЖЕТА
              // ==========================================
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Текущая фаза: ${state.phase == "stats" ? "Калибровка (Сбор статистики)" : "Контроль лимита"}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Потрачено дофамина за сегодня:',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      Text(
                        '${state.pointsSpentToday} XP',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: state.isOverLimit ? Colors.red : Theme.of(context).primaryColor,
                            ),
                      ),
                      if (state.phase == "control") ...[
                        const SizedBox(height: 10),
                        Text(
                          'Ваш дневной лимит: ${state.dailyLimit} XP',
                          style: const TextStyle(fontSize: 16, color: Colors.redAccent, fontWeight: FontWeight.bold),
                        ),
                      ],
                      const SizedBox(height: 40),
                      // ==========================================
                      // БЛОК 3: ТРИГГЕР ДЕЙСТВИЯ (КНОПКА КЛАЦ)
                      // ==========================================
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          // Передаем тип привычки "1" и вес "1 балл" строго в твой spendDopamine
                          await scoringNotifier.spendDopamine("1", 1);
                        },
                        child: const Text('Клац! 🚨'),
                      ),
                    ],
                  ),
                ),
              ),

              // ==========================================
              // БЛОК 4: ИНСТРУМЕНТЫ ОТЛАДКИ (DEBUG UI)
              // ==========================================
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: Colors.amber.shade50,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Text(
                          '🎛️ Панель отладки времени',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade900),
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
                                // Если TimeProvider ругнется, проверим его импорт
                                TimeProvider.addDuration(const Duration(days: 1));
                                await scoringNotifier.checkAndResetDayIfNeeded();
                              },
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade300,
                                foregroundColor: Colors.black54,
                              ),
                              child: const Text('Сбросить время'),
                              onPressed: () async {
                                TimeProvider.reset();
                                await scoringNotifier.refreshTodayState();
                              },
                            ),
                          ],
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