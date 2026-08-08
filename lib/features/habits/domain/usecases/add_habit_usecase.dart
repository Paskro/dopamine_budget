import '../entities/habit.dart';
import '../repositories/habit_repository.dart';
import 'package:dopamine_budget/core/sync/sync_service.dart';
import 'package:dopamine_budget/core/errors/habit_limit_exceeded_exception.dart';

class AddHabitUseCase {
  final HabitRepository repository;
  final SyncService? sync;

  AddHabitUseCase(this.repository, {this.sync});

  Future<void> execute(Habit habit) async {
    if (habit.sessionId != null) {
      final current = await repository.getHabitsForSession(habit.sessionId!);
      if (current.length >= 6) throw const HabitLimitExceededException();
    }
    await repository.addHabit(habit);
    sync?.pushHabits().catchError((_) {});
    sync?.pushSessionHabits().catchError((_) {});
  }
}
