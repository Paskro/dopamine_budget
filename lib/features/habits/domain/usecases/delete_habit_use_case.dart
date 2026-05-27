import '../repositories/habit_repository.dart';

class DeleteHabitUseCase {
  final HabitRepository repository;

  DeleteHabitUseCase(this.repository);

  Future<void> execute(String id) async {
    return await repository.deleteHabit(id);
  }
}