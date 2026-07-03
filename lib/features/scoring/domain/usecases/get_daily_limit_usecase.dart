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

    final period = await _sessionRepository
        .getActiveShrinkingPeriod(session.id);

    if (period == null) {
      return session.shrunkenLimit ?? session.avgScore;
    }

    final today = DateTime(
      TimeProvider.now.year,
      TimeProvider.now.month,
      TimeProvider.now.day,
    );
    final startDay = DateTime(
      period.startedAt.year,
      period.startedAt.month,
      period.startedAt.day,
    );
    final daysPassed = today.difference(startDay).inDays;
    final steps = daysPassed ~/ period.intervalDays;
    final result = period.baseLimit * (1.0 - steps * period.decreasePct);

    return max(minDailyLimit, result);
  }
}