import 'dart:math';
import 'package:dopamine_budget/core/utils/time_provider.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';

class GetDailyLimitUseCase {
  static const double minDailyLimit = 0.0;

  final SessionRepository _sessionRepository;

  GetDailyLimitUseCase(this._sessionRepository);

  Future<double?> execute() async {
    final session = await _sessionRepository.getActiveSession();
    if (session == null || session.phase == 0) return null;

    final baseLimit = session.baseShrinkingLimit ?? session.avgScore;
    if (baseLimit == null) return null;

    if (session.shrinkingStartedAt == null) return baseLimit;

    final daysPassed = TimeProvider.now
        .difference(session.shrinkingStartedAt!)
        .inDays;
    final steps = daysPassed ~/ (session.decreaseIntervalDays ?? 7);
    final dailyLimit = baseLimit * (1.0 - (steps * (session.decreasePercentage ?? 0.0)));

    return max(minDailyLimit, dailyLimit);
  }
}