import 'package:dopamine_budget/features/habits/domain/entities/habit.dart';
import 'package:dopamine_budget/core/utils/time_provider.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';

class AddActionUseCase {
  final SessionRepository _sessionRepository;

  AddActionUseCase(this._sessionRepository);

  Future<void> execute(Habit habit) async {
    await _sessionRepository.logHabitClickWithStatusCheck(
      habitId: habit.id,
      scoreCost: habit.scoreValue,
      timestamp: TimeProvider.now,
    );
  }
}