import 'package:flutter/material.dart';
import 'package:dopamine_budget/features/habits/domain/entities/habit.dart';
import 'package:dopamine_budget/features/habits/domain/repositories/habit_repository.dart';
import 'package:dopamine_budget/features/actions/domain/usecases/add_action_usecase.dart';

class HabitsNotifier extends ChangeNotifier {
  final HabitRepository _habitRepository;
  final AddActionUseCase _addActionUseCase;

  HabitsNotifier({
    required HabitRepository habitRepository,
    required AddActionUseCase addActionUseCase,
  })  : _habitRepository = habitRepository,
        _addActionUseCase = addActionUseCase {
    loadHabits();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Habit> _habits = [];
  List<Habit> get habits => _habits;

  List<int> _selectedHabitIds = [];
  List<int> get selectedHabitIds => _selectedHabitIds;

  String? _currentSessionId;

  Future<void> loadHabits({String? currentSessionId}) async {
    if (currentSessionId != null) {
      _currentSessionId = currentSessionId;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _habits = await _habitRepository.getHabits();

      if (_currentSessionId != null) {
        _selectedHabitIds = await _habitRepository
            .getSelectedHabitIdsForSession(_currentSessionId!);
      }
    } catch (e) {
      debugPrint('Ошибка загрузки привычек: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleHabitSelection(String sessionId, int habitId) async {
    await _habitRepository.toggleHabitSelection(sessionId, habitId);
    await loadHabits(currentSessionId: sessionId);
  }

  Future<void> addHabit(String title, int scoreValue) async {
    final newHabit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      scoreValue: scoreValue,
    );
    await _habitRepository.addHabit(newHabit);
    await loadHabits();
  }

  Future<void> updateHabit(Habit habit) async {
    await _habitRepository.updateHabit(habit);
    await loadHabits();
  }

  Future<void> deleteHabit(int habitId, {String? sessionId}) async {
    await _habitRepository.deleteHabit(habitId);
    await loadHabits(currentSessionId: sessionId);
  }

  /// Старый метод фиксации (оставляем для обратной совместимости)
  Future<void> hitHabit(Habit habit, {dynamic scoringNotifier}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _addActionUseCase.execute(habit);

      if (scoringNotifier != null) {
        await scoringNotifier.refreshScore();
      }
    } catch (e) {
      debugPrint('Ошибка при записи срыва (hitHabit): $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🎯 НОВЫЙ МЕТОД: Специально для интерактивной кнопки удержания на HomePage.

   Future<void> addActionLog({
     required String habitId,
     required int points,
     required DateTime timestamp,
   }) async {
     _isLoading = true;
     notifyListeners();

     try {
       // Собираем объект Habit, так как execute ждет именно его
       // (поля сверяем с твоим методом addHabit: title и scoreValue)
       final habit = _habits.firstWhere(
         (h) => h.id == habitId,
         orElse: () => Habit(id: habitId, title: habitId, scoreValue: points),
       );
       await _addActionUseCase.execute(habit);

     } catch (e) {
       debugPrint('Ошибка при записи действия в addActionLog: $e');
     } finally {
       _isLoading = false;
       notifyListeners();
     }
   }
}