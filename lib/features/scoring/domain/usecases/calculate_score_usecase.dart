import '../../../sessions/domain/entities/session.dart'; // Корректируй путь, если сессии лежат в другом месте
import '../repositories/scoring_repository.dart';
import 'package:dopamine_budget/core/utils/time_provider.dart';

class CalculateScoreUseCase {
  final ScoringRepository _repository;

  CalculateScoreUseCase(this._repository);

  // ==========================================
  // БЛОК 1: БИЗНЕС-ЛОГИКА РАСЧЕТА БЮДЖЕТА И ФАЗ
  // ==========================================

  /// Рассчитывает состояние бюджета и проверяет завершение калибровки.
   /// Возвращает кортеж: (bool фаза_изменилась, Session обновленная_сессия).
  Future<(bool, Session)> checkAndProcessCalibration(Session session) async {
      if (session.phase != 0) {
        return (false, session);
      }

      try {
        final List<DateTime> recordedDays = await _repository.getUniqueRecordedDays();
        recordedDays.sort((a, b) => a.compareTo(b));

        final int targetCalibrationDays = (session.decreaseInterval != null && session.decreaseInterval! > 0)
            ? session.decreaseInterval!
            : 3;

        // ИСПРАВЛЕНИЕ: Убрали скобки (), так как это геттер, возвращающий DateTime
        final virtualNow = TimeProvider.now;
        final todayDate = DateTime(virtualNow.year, virtualNow.month, virtualNow.day);

        // Считаем полные дни, которые были строго ДО виртуального "сегодня"
        final int completedDaysCount = recordedDays.where((date) {
          final cleanDate = DateTime(date.year, date.month, date.day);
          return cleanDate.isBefore(todayDate);
        }).length;

        print('📊 Логика калибровки: Полных дней позади: $completedDaysCount из $targetCalibrationDays необходимых. Виртуальная дата: $todayDate');

        if (completedDaysCount < targetCalibrationDays) {
          return (false, session);
        }

        int totalScore = 0;
        final daysToCalculate = recordedDays.take(targetCalibrationDays).toList();

        for (var day in daysToCalculate) {
          totalScore += await _repository.getScoreForDay(day);
        }

        final double calculatedAvg = totalScore / targetCalibrationDays;

        final updatedSession = session.copyWith(
          avgScore: calculatedAvg,
          phase: 1,
        );

        print('🚀 Калибровка успешно завершена! Средний балл: $calculatedAvg');
        return (true, updatedSession);
      } catch (e) {
        print('Ошибка при обработке калибровки: $e');
      }

      return (false, session);
    }

  /// Метод получения чистой суммы потраченных очков за день
  Future<int> getScoreForDay(DateTime date) async {
    return await _repository.getScoreForDay(date);
  }

  // ==========================================
  // БЛОК 2: УПРАВЛЕНИЕ ДЕЙСТВИЯМИ И СТАТИСТИКОЙ
  // ==========================================

  /// Запись нового нажатия (штрафа) через репозиторий
  Future<void> registerAction({
    required String habitType,
    required int scoreValue,
    DateTime? timestamp,
  }) async {
    final executionTime = timestamp ?? DateTime.now();

    await _repository.saveAction(
      habitType: habitType,
      scoreValue: scoreValue,
      timestamp: executionTime,
    );
  }

  /// Получение статистики кликов за выбранный день (для UI)
  Future<Map<String, int>> getTodayHabitClicks(DateTime date) async {
    final dynamic rawClicks = await _repository.getHabitClicksForDay(date);

    final Map<String, int> typedClicks = {};
    if (rawClicks is Map) {
      rawClicks.forEach((key, value) {
        typedClicks[key.toString()] = (value as num).toInt();
      });
    }
    return typedClicks;
  }
  /// Расчет текущего баланса Score на лету по логам из базы данных за выбранную дату
    Future<double> execute({DateTime? forDate}) async {
      // 1. Берем дату (используем виртуальное "сегодня" через TimeProvider)
      final targetDate = forDate ?? TimeProvider.now;

      // 2. Получаем текущую активную сессию через единый репозиторий
      final currentSession = await _repository.getActiveSession();
      if (currentSession == null) return 0.0;

      // 3. Запрашиваем из базы сумму стоимости всех штрафных действий за эти сутки
      final totalSpentInt = await _repository.getTotalScoreCostForDate(targetDate);
      final totalSpent = totalSpentInt.toDouble();

      // 4. Бизнес-логика расчета в зависимости от фазы сессии
      if (currentSession.phase == 0) {
        // На этапе калибровки лимита нет — показываем чистый расход со знаком минус
        return -totalSpent;
      } else {
        // На этапе контроля вычитаем расход из доступного динамического лимита дня
        final limit = currentSession.dailyLimit ?? 0.0;
        return limit - totalSpent;
      }
    }
}