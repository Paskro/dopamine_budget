import 'package:flutter/material.dart';
import 'package:dopamine_budget/features/actions/domain/usecases/add_action_usecase.dart';
import 'package:dopamine_budget/features/scoring/domain/usecases/calculate_score_usecase.dart';
import 'package:dopamine_budget/features/habits/domain/entities/habit.dart';

class ScoringState {
  final int score;
  final bool isLoading;

  const ScoringState({
    this.score = 100,
    this.isLoading = false,
  });
}

class ScoringNotifier extends ChangeNotifier {
  final AddActionUseCase addActionUseCase; // Наш новый UseCase
  final CalculateScoreUseCase calculateScoreUseCase;

  ScoringState _state = const ScoringState(isLoading: true);
  ScoringState get state => _state;

  ScoringNotifier({
    required this.addActionUseCase,
    required this.calculateScoreUseCase,
  }) {
    refreshScore();
  }

  Future<void> refreshScore() async {
    _state = ScoringState(score: _state.score, isLoading: true);
    notifyListeners();

    final realScore = await calculateScoreUseCase();

    _state = ScoringState(score: realScore, isLoading: false);
    notifyListeners();
  }

  // Фиксация срыва по конкретной привычке
  Future<void> SpendDopamine(Habit habit) async {
    try {
      // Вызываем правильный UseCase, который пишет в ActionsTable
      await addActionUseCase.execute(habit);
      print('=== Лог срыва успешно записан в ActionsTable для "${habit.title}" ===');

      // Принудительно пересчитываем баланс
      await refreshScore();
    } catch (e) {
      print('Ошибка при сохранении лога срыва в SQL: $e');
    }
  }
}