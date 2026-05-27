import 'package:flutter/material.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/initialize_session_usecase.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/start_control_session_usecase.dart';

class SessionsState {
  final Session? currentSession;
  final bool isLoading;

  const SessionsState({
    this.currentSession,
    this.isLoading = false,
  });
}

class SessionsNotifier extends ChangeNotifier {
  final InitializeSessionUseCase initializeSessionUseCase;
  final StartControlSessionUseCase startControlSessionUseCase;

  SessionsState _state = const SessionsState(isLoading: true);
  SessionsState get state => _state;

  SessionsNotifier({
    required this.initializeSessionUseCase,
    required this.startControlSessionUseCase,
  }) {
    loadCurrentSession();
  }

  Future<void> loadCurrentSession() async {
    _state = SessionsState(currentSession: _state.currentSession, isLoading: true);
    notifyListeners();

    final session = await initializeSessionUseCase.execute();

    _state = SessionsState(currentSession: session, isLoading: false);
    notifyListeners();
  }

  // Обновили: теперь принимаем гибкое количество дней для калибровки
  Future<void> restartCalibration({int durationDays = 7}) async {
    _state = const SessionsState(isLoading: true);
    notifyListeners();

    final session = await initializeSessionUseCase.execute(
      forceRestart: true,
      durationDays: durationDays,
    );

    _state = SessionsState(currentSession: session, isLoading: false);
    notifyListeners();
  }

  // Обновили: теперь прокидываем все параметры усыхания лимита в UseCase
  Future<void> startManualControl({
    required double limit,
    required bool shouldDecrease,
    double? decreasePercentage,
    String? decreaseInterval,
  }) async {
    _state = const SessionsState(isLoading: true);
    notifyListeners();

    final session = await startControlSessionUseCase.execute(
      manualLimit: limit,
      shouldDecrease: shouldDecrease,
      decreasePercentage: decreasePercentage,
      decreaseInterval: decreaseInterval,
    );

    _state = SessionsState(currentSession: session, isLoading: false);
    notifyListeners();
  }
}