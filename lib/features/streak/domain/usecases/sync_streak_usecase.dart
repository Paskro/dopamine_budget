import 'package:dopamine_budget/features/streak/domain/repositories/i_streak_repository.dart';
import 'package:dopamine_budget/features/streak/domain/entities/streak_record.dart';

class SyncStreakUseCase {
  final IStreakRepository _repository;

  SyncStreakUseCase(this._repository);

  Future<StreakRecord?> execute() async {
    await _repository.syncStreak();
    return _repository.getStreak();
  }
}