import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/features/scoring/domain/usecases/get_current_dopamine_balance_usecase.dart';
import 'package:dopamine_budget/features/sessions/presentation/state/control_screen_notifier.dart';

// lib/core/di/control_screen_di.dart

/// Отдельный DI-узел для экрана контроля.
/// Зависит от SessionRepository (из SessionsDI) и
/// GetCurrentDopamineBalanceUseCase (из ScoringDI).
class ControlScreenDI {
  late final ControlScreenNotifier notifier;

  ControlScreenDI({
    required SessionRepository sessionRepository,
    required GetCurrentDopamineBalanceUseCase getDopamineBalance,
  }) {
    notifier = ControlScreenNotifier(
      sessionRepository: sessionRepository,
      getDopamineBalance: getDopamineBalance,
    );
  }
}