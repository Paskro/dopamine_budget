// lib/features/sessions/domain/usecases/record_action_usecase.dart

import 'package:dopamine_budget/core/utils/time_provider.dart';
import 'package:dopamine_budget/features/habits/domain/repositories/habit_repository.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';

class RecordActionUseCase {
  final HabitRepository _habitRepository;
  final SessionRepository _sessionRepository; // Предполагаем добавление метода логгирования действий

  RecordActionUseCase({
    required HabitRepository habitRepository,
    required SessionRepository sessionRepository,
  })  : _habitRepository = habitRepository,
        _sessionRepository = sessionRepository;

  Future<void> execute(String habitId) async {
    // 1. Получаем привычку для фиксации стоимости балла в момент клика
    final habits = await _habitRepository.getHabits();
    final habit = habits.firstWhere((h) => h.id == habitId,
      orElse: () => throw Exception('Habit with id $habitId not found'));

    // 2. Гарантируем синхронизацию по глобальному TimeProvider
    final timestamp = TimeProvider.now;

    // 3. Вызываем метод репозитория для вставки лога в ActionsTable
    await _sessionRepository.recordActionLog(
      habitId: habit.id,
      scoreCost: habit.scoreValue,
      createdAt: timestamp,
    );
  }
}