import '../../../sessions/domain/entities/session.dart'; // Корректируй путь, если сессии лежат в другом месте
import '../repositories/scoring_repository.dart';
import 'package:dopamine_budget/core/utils/time_provider.dart';
import 'package:dopamine_budget/features/scoring/domain/usecases/get_daily_limit_usecase.dart';

class CalculateScoreUseCase {
  final ScoringRepository _repository;
  final GetDailyLimitUseCase _getDailyLimitUseCase;

  CalculateScoreUseCase(this._repository, this._getDailyLimitUseCase);

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
        final List<DateTime> recordedDays = await _repository.getUniqueRecordedDays(
          sessionId: session.id,
        );
        recordedDays.sort((a, b) => a.compareTo(b));

        final int targetCalibrationDays = session.calibrationDays;

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
    final executionTime = timestamp ?? TimeProvider.now;

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
    final targetDate = forDate ?? TimeProvider.now;
    final currentSession = await _repository.getActiveSession();
    if (currentSession == null) return 0.0;

    final totalSpent = (await _repository.getTotalScoreCostForDate(targetDate)).toDouble();

    if (currentSession.phase == 0) return -totalSpent;

    final limit = await _getDailyLimitUseCase.execute() ?? 0.0;
    return limit - totalSpent;
  }
}