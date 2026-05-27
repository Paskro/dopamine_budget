import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class AddHabitUseCase {
  final HabitRepository repository;

  AddHabitUseCase(this.repository);

  Future<void> execute(Habit habit) async {
    await repository.addHabit(habit);
  }
}