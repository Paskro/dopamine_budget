import 'package:dopamine_budget/core/utils/time_provider.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/shrinking_period.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/features/scoring/domain/usecases/get_daily_limit_usecase.dart';
import 'package:dopamine_budget/core/notifications/notification_scheduler.dart';
import 'package:dopamine_budget/core/notifications/notification_prefs.dart';

class ToggleShrinkingModeUseCase {
  final SessionRepository _sessionRepository;
  final GetDailyLimitUseCase _getDailyLimitUseCase;

  ToggleShrinkingModeUseCase({
    required SessionRepository sessionRepository,
    required GetDailyLimitUseCase getDailyLimitUseCase,
  })  : _sessionRepository = sessionRepository,
        _getDailyLimitUseCase = getDailyLimitUseCase;

  Future<void> execute({
    required bool isEnabled,
    double? decreasePct,
    int? intervalDays,
  }) async {
    final session = await _sessionRepository.getActiveSession();
    if (session == null) throw StateError('Нет активной сессии');

    if (isEnabled) {
      final baseLimit = session.shrunkenLimit ?? session.avgScore;
      if (baseLimit == null) throw StateError('Нет базового лимита для усыхания');
      if (decreasePct == null || intervalDays == null) {
        throw ArgumentError('decreasePct и intervalDays обязательны при активации');
      }

      final today = DateTime(
        TimeProvider.now.year,
        TimeProvider.now.month,
        TimeProvider.now.day,
      );

      await _sessionRepository.insertShrinkingPeriod(ShrinkingPeriod(
        sessionId: session.id,
        startedAt: today,
        baseLimit: baseLimit,
        decreasePct: decreasePct,
        intervalDays: intervalDays,
      ));
      final notifyTime = await NotificationPrefs.getShrinkNotifyTime();
      final reportDay = today.add(Duration(days: intervalDays));
      await NotificationScheduler.scheduleNextShrinkPush(
        reportDay: reportDay,
        notifyTime: notifyTime,
      );

    } else {
      final period = await _sessionRepository.getActiveShrinkingPeriod(session.id);
      if (period == null) return;

      final currentLimit = await _getDailyLimitUseCase.execute() ?? period.baseLimit;
      final todayStr = _fmt(TimeProvider.now);

      await _sessionRepository.closeShrinkingPeriod(
        periodId: period.id!,
        endedAt: todayStr,
        shrunkenLimit: currentLimit,
      );
      await NotificationScheduler.cancelShrinkPush();
    }
  }

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';
}