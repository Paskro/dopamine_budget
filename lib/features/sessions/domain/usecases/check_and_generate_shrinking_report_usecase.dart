import 'package:dopamine_budget/core/utils/time_provider.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/shrinking_period.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/features/scoring/domain/usecases/get_daily_limit_usecase.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/day_stats.dart';

class ShrinkingReportData {
  final DateTime weekStart;
  final DateTime weekEnd;
  final int periodIndex;
  final double baseLimit;
  final double currentLimit;
  final double nextLimit;
  final int shrinkCount;
  final double? prevAvgRemaining;
  final double? thisAvgRemaining;
  final int? prevBrokenDays;
  final int? thisBrokenDays;
  final String sessionMode;
  final bool isEditAllowed;
  final ShrinkingPeriod activePeriod;

  const ShrinkingReportData({
    required this.weekStart,
    required this.weekEnd,
    required this.periodIndex,
    required this.baseLimit,
    required this.currentLimit,
    required this.nextLimit,
    required this.shrinkCount,
    this.prevAvgRemaining,
    this.thisAvgRemaining,
    this.prevBrokenDays,
    this.thisBrokenDays,
    this.sessionMode = 'basic',
    required this.isEditAllowed,
    required this.activePeriod,
  });
}

class CheckAndGenerateShrinkingReportUseCase {
  final SessionRepository _sessionRepository;
  final GetDailyLimitUseCase _getDailyLimitUseCase;

  CheckAndGenerateShrinkingReportUseCase({
    required SessionRepository sessionRepository,
    required GetDailyLimitUseCase getDailyLimitUseCase,
  })  : _sessionRepository = sessionRepository,
        _getDailyLimitUseCase = getDailyLimitUseCase;

  Future<ShrinkingReportData?> execute() async {
    final session = await _sessionRepository.getActiveSession();
    if (session == null || session.phase != 1) return null;

    final period = await _sessionRepository.getActiveShrinkingPeriod(session.id);
    if (period == null) return null;

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
    if (daysPassed < period.intervalDays) return null;

    final periodIndex = daysPassed ~/ period.intervalDays;
    final reportWeekStart = startDay
        .add(Duration(days: (periodIndex - 1) * period.intervalDays));
    final reportWeekEnd = reportWeekStart
        .add(Duration(days: period.intervalDays - 1));

    final isReviewed = await _sessionRepository
        .isShrinkingReportReviewed(session.id, reportWeekStart);
    if (isReviewed) return null;

    final currentLimit = period.baseLimit *
        (1.0 - (periodIndex - 1) * period.decreasePct);
    final nextLimit = period.baseLimit *
        (1.0 - periodIndex * period.decreasePct);

    final shrinkCount = await _sessionRepository
        .getShrinkingPeriodsCount(session.id);

    final prevStart = reportWeekStart
        .subtract(Duration(days: period.intervalDays));
    final prevEnd = reportWeekStart.subtract(const Duration(days: 1));

    final prevStats = await _sessionRepository
        .getDayStatsForRange(prevStart, prevEnd);
    final thisStats = await _sessionRepository
        .getDayStatsForRange(reportWeekStart, reportWeekEnd);

    return ShrinkingReportData(
      weekStart: reportWeekStart,
      weekEnd: reportWeekEnd,
      periodIndex: periodIndex,
      baseLimit: session.avgScore ?? period.baseLimit,
      currentLimit: currentLimit,
      nextLimit: nextLimit.clamp(0.0, double.infinity),
      shrinkCount: shrinkCount,
      prevAvgRemaining: _calcAvgRemaining(prevStats, currentLimit),
      thisAvgRemaining: _calcAvgRemaining(thisStats, currentLimit),
      prevBrokenDays: _countBroken(prevStats),
      thisBrokenDays: _countBroken(thisStats),
      sessionMode: 'basic',
      isEditAllowed: true,
      activePeriod: period,
    );
  }

  double? _calcAvgRemaining(List<DayStats>? stats, double limit) {
    if (stats == null || stats.isEmpty) return null;
    final valid = stats.where((s) => !s.isBroken).toList();
    if (valid.isEmpty) return null;
    final sum = valid.fold<double>(0, (acc, s) => acc + (limit - s.spent));
    return sum / valid.length;
  }

  int _countBroken(List<DayStats>? stats) =>
      stats?.where((s) => s.isBroken).length ?? 0;
}