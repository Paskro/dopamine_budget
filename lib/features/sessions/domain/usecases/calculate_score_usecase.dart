// lib/features/sessions/domain/usecases/calculate_score_usecase.dart

import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';

class CalculateScoreUseCase {
  final SessionRepository _sessionRepository;

  CalculateScoreUseCase(this._sessionRepository);

  /// Возвращает общий дофаминовый расход (сумму баллов) за конкретный день
  Future<int> execute(DateTime date) async {
    // Репозиторий должен уметь собирать логи действий строго в диапазоне суток [00:00:00 - 23:59:59]
    final totalSpent = await _sessionRepository.getTotalScoreSpentByDay(date);
    return totalSpent;
  }
}