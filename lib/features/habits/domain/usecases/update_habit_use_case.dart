import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class UpdateHabitUseCase {
  final HabitRepository repository;

  UpdateHabitUseCase(this.repository);

  Future<void> execute(Habit habit) async {
    return await repository.updateHabit(habit);
  }
}