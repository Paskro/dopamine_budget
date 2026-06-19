import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/initialize_session_usecase.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/start_control_session_usecase.dart';

// lib/features/sessions/presentation/state/sessions_notifier.dart

class SessionsState {
  final Session? currentSession;
  final bool isLoading;

  const SessionsState({
    this.currentSession,
    this.isLoading = false,
  });
}

/// Single Source of Truth для текущей сессии.
/// Подписывается на watchActiveSession() один раз в конструкторе —
/// любая мутация в SessionsTable (включая VerifyCalibrationExpiryUseCase,
/// который меняет phase напрямую через repository) автоматически
/// долетает сюда без ручных loadCurrentSession()/checkForNewDay().
class SessionsNotifier extends ChangeNotifier {
  final SessionRepository _sessionRepository;
  final InitializeSessionUseCase initializeSessionUseCase;
  final StartControlSessionUseCase startControlSessionUseCase;

  SessionsState _state = const SessionsState(isLoading: true);
  SessionsState get state => _state;

  StreamSubscription<Session?>? _sub;

  SessionsNotifier({
    required SessionRepository sessionRepository,
    required this.initializeSessionUseCase,
    required this.startControlSessionUseCase,
  }) : _sessionRepository = sessionRepository {
    _sub = _sessionRepository.watchActiveSession().listen((session) {
      _state = SessionsState(currentSession: session, isLoading: false);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  /// Запускает калибровку (создаёт новую сессию в БД).
  /// Состояние обновится автоматически через стрим — не нужно
  /// присваивать _state вручную после успешного INSERT.
  Future<void> restartCalibration({int durationDays = 7}) async {
    await initializeSessionUseCase.execute(
      forceRestart: true,
      durationDays: durationDays,
    );
    // _state обновится сам через watchActiveSession() — INSERT в SessionsTable
    // триггерит стрим автоматически.
  }

  Future<void> startManualControl({
    required double limit,
    required bool shouldDecrease,
    double? decreasePercentage,
    String? decreaseInterval,
  }) async {
    await startControlSessionUseCase.execute(
      manualLimit: limit,
      shouldDecrease: shouldDecrease,
      decreasePercentage: decreasePercentage,
      decreaseInterval: decreaseInterval,
    );
    // Аналогично — стрим подхватит новую сессию сам.
  }

  Future<void> updateSession(Session session) async {
    await _sessionRepository.updateSession(session);
  }
}