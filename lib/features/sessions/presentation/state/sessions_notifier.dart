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

  /// Проверка смены календарного дня
  Future<void> checkForNewDay() async {
    final session = _state.currentSession;
    if (session == null) return;

    final DateTime now = DateTime.now();

    // Подстраиваемся под архитектуру сущности Session.
    // Если в классе Session поле называется по-другому, замени .createdAt на него
    final DateTime lastOpened = session.createdAt;

    final bool isNewDay = DateTime(now.year, now.month, now.day).isAfter(
      DateTime(lastOpened.year, lastOpened.month, lastOpened.day),
    );

    if (isNewDay) {
      _state = SessionsState(currentSession: _state.currentSession, isLoading: true);
      notifyListeners();

      final updatedSession = await initializeSessionUseCase.execute();

      _state = SessionsState(currentSession: updatedSession, isLoading: false);
      notifyListeners();
    }
  }

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