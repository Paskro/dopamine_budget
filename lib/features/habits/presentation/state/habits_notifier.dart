import 'package:flutter/material.dart';
import 'package:dopamine_budget/features/habits/domain/entities/habit.dart';
import 'package:dopamine_budget/features/habits/domain/usecases/get_habits_usecase.dart';
import 'package:dopamine_budget/features/habits/domain/usecases/add_habit_usecase.dart';
import 'package:dopamine_budget/features/habits/domain/usecases/update_habit_use_case.dart';
import 'package:dopamine_budget/features/habits/domain/usecases/delete_habit_use_case.dart';

// Возвращаем класс состояния, который требует твой habits_page.dart!
class HabitsState {
  final List<Habit> habits;
  final bool isLoading;

  const HabitsState({
    this.habits = const [],
    this.isLoading = false,
  });

  HabitsState copyWith({
    List<Habit>? habits,
    bool? isLoading,
  }) {
    return HabitsState(
      habits: habits ?? this.habits,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class HabitsNotifier extends ChangeNotifier {
  final GetHabitsUseCase getHabitsUseCase;
  final AddHabitUseCase addHabitUseCase;
  final UpdateHabitUseCase updateHabitUseCase;
  final DeleteHabitUseCase deleteHabitUseCase;

  HabitsState _state = const HabitsState();
  HabitsState get state => _state;

  HabitsNotifier({
    required this.getHabitsUseCase,
    required this.addHabitUseCase,
    required this.updateHabitUseCase,
    required this.deleteHabitUseCase,
  });

  Future<void> loadHabits() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final list = await getHabitsUseCase.execute();
      _state = _state.copyWith(habits: list, isLoading: false);
    } catch (e) {
      _state = _state.copyWith(isLoading: false);
      print('Ошибка Notifier при загрузке: $e');
    }
    notifyListeners();
  }

  Future<void> createHabit(String title, int score) async {
      final newHabit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        scoreValue: score,
      );

      try {
        // 1. Сначала сохраняем в базу данных
        await addHabitUseCase.execute(newHabit);

        // 2. Локально добавляем в текущее состояние, чтобы UI обновился мгновенно
        final updatedList = List<Habit>.from(_state.habits)..add(newHabit);
        _state = _state.copyWith(habits: updatedList);
        notifyListeners(); // Громко говорим экрану обновиться!

        // 3. На всякий случай синхронизируем с базой данных
        await loadHabits();
      } catch (e) {
        print('Ошибка при создании привычки в Notifier: $e');
      }
    }

  // Для обратной совместимости со старым кодом страницы
  Future<void> addHabit(String title, int score) async {
    await createHabit(title, score);
  }

  Future<void> deleteHabit(String id) async {
    await deleteHabitUseCase.execute(id);
    await loadHabits();
  }

  Future<void> updateHabit(Habit habit) async {
    await updateHabitUseCase.execute(habit);
    await loadHabits();
  }
}