import '../entities/habit.dart';
import '../repositories/habit_repository.dart';
import 'package:dopamine_budget/core/sync/sync_service.dart';

class AddHabitUseCase {
  final HabitRepository repository;
  final SyncService? sync;

  AddHabitUseCase(this.repository, {this.sync});

  Future<void> execute(Habit habit) async {
    await repository.addHabit(habit);
    sync?.pushHabits().catchError((_) {});
    sync?.pushSessionHabits().catchError((_) {});
  }
}