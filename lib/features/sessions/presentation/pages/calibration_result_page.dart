import 'package:flutter/material.dart';
import 'package:dopamine_budget/features/scoring/presentation/state/scoring_notifier.dart';

class CalibrationResultPage extends StatelessWidget {
  final dynamic session;
  final List<double> historicalScores;
  final ScoringNotifier scoringNotifier; // передаём явно — без Provider

  const CalibrationResultPage({
    Key? key,
    required this.session,
    required this.historicalScores,
    required this.scoringNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Округление среднего балла до целого (математическое)
    final String displayAvg = (session.avgScore ?? 0.0).round().toString();

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Тема приложения (Dark)
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // 🎉 Заголовок и иконка успеха
              const Icon(Icons.emoji_events_rounded, size: 80, color: Colors.amber),
              const SizedBox(height: 24),
              const Text(
                'Калибровка завершена!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),
              const Text(
                'Мы проанализировали ваши триггеры и рассчитали персональный лимит.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),

              const Spacer(),

              // 🏆 БЛОК АНАЛИТИКИ: Самая частая привычка
              FutureBuilder<String?>(
                future: scoringNotifier.getMostFrequentHabit(session.createdAt),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }
                  final habitName = snapshot.data;
                  if (habitName == null || habitName.isEmpty) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.emoji_flags_rounded, color: Colors.amber, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Самая частая привычка',
                                  style: TextStyle(color: Colors.white60, fontSize: 12)),
                              const SizedBox(height: 2),
                              Text(habitName,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // 📊 БЛОК ГРАФИКА: Динамика по дням
              const Text(
                'Ваша дофаминовая нагрузка:',
                style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              _buildSimpleBarChart(historicalScores),

              const Spacer(),

              // 💡 Информационный блок с результатами
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Ваш базовый ежедневный бюджет:',
                      style: TextStyle(color: Colors.white60, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$displayAvg баллов',
                      style: const TextStyle(color: Colors.amber, fontSize: 32, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Теперь каждый клик по деструктивной привычке будет вычитаться из этого бюджета. Удерживайте баланс выше нуля!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // 🚀 Акцентная кнопка "Быстрый старт"
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () async {
                  await scoringNotifier.applyDefaultControlSettings();
                },
                child: const Text(
                  'Поехали!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

              // ⚙️ Неактивная кнопка "Настроить сессию" (Задел на Спринт 4)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: null, // Отключаем по ТЗ для MVP v2
                child: Text(
                  'Кастомные настройки (Скоро)',
                  style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // Простой декларативный мини-график на контейнерах без внешних библиотек
  Widget _buildSimpleBarChart(List<double> scores) {
    if (scores.isEmpty) return const SizedBox(height: 100, child: Center(child: Text('Нет данных', style: TextStyle(color: Colors.grey))));

    final maxScore = scores.reduce((a, b) => a > b ? a : b);

    return Container(
      height: 130,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(scores.length, (index) {
          final score = scores[index];
          // Рассчитываем пропорциональную высоту столбца
          final heightFactor = maxScore > 0 ? (score / maxScore) : 0.0;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(score.toStringAsFixed(0), style: const TextStyle(color: Colors.white60, fontSize: 11)),
              const SizedBox(height: 4),
              Container(
                width: 32,
                height: (heightFactor * 70).clamp(4.0, 70.0), // Ограничиваем высоту от 4 до 70 пикселей
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.7),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ),
              const SizedBox(height: 4),
              Text('День ${index + 1}', style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          );
        }),
      ),
    );
  }
}