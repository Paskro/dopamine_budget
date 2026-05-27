import '../repositories/scoring_repository.dart';

class CalculateScoreUseCase {
  final ScoringRepository _repository;

  CalculateScoreUseCase(this._repository);

  // ==========================================
  // БЛОК 1: БИЗНЕС-ЛОГИКА РАСЧЕТА БЮДЖЕТА
  // ==========================================

  /// Основной метод расчета оставшегося дофаминового бюджета (калибровка)
  Future<int> call() async {
    const int startBudget = 100; // Базовый дефолт для режима калибровки
    try {
      final now = DateTime.now();
      final int todayPenalty = await _repository.getScoreForDay(now);
      return startBudget - todayPenalty;
    } catch (e) {
      print('Ошибка при расчете баланса в UseCase: $e');
      return startBudget;
    }
  }

  /// Метод получения чистой суммы потраченных очков за день (для режима контроля)
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
  }) async {
    await _repository.saveAction(
      habitType: habitType,
      scoreValue: scoreValue,
      timestamp: DateTime.now(),
    );
  }

  /// Получение статистики кликов за сегодня (для UI)
  Future<Map<String, int>> getTodayHabitClicks() async {
    return await _repository.getHabitClicksForDay(DateTime.now());
  }
}