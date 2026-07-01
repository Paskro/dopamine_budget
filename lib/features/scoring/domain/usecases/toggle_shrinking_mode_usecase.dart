import 'package:drift/drift.dart';
import 'package:dopamine_budget/core/utils/time_provider.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/features/scoring/domain/usecases/get_daily_limit_usecase.dart';

class ToggleShrinkingModeUseCase {
  final SessionRepository _sessionRepository;
  final GetDailyLimitUseCase _getDailyLimitUseCase;

  ToggleShrinkingModeUseCase({
    required SessionRepository sessionRepository,
    required GetDailyLimitUseCase getDailyLimitUseCase,
  })  : _sessionRepository = sessionRepository,
        _getDailyLimitUseCase = getDailyLimitUseCase;

  Future<void> execute(bool isEnabled) async {
    if (isEnabled) {
      await _sessionRepository.updateShrinkingState(
        shrinkingStartedAt: Value(TimeProvider.now),
      );
    } else {
      final currentLimit = await _getDailyLimitUseCase.execute() ?? 0.0;
      await _sessionRepository.updateShrinkingState(
        baseShrinkingLimit: Value(currentLimit),
        shrinkingStartedAt: const Value(null),
      );
    }
  }
}