import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/day_log.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/core/utils/time_provider.dart';

class WeeklyReportData {
  final int weekNumber;
  final DateTime weekStart;
  final DateTime weekEnd;

  /// 7 слотов строго по календарю. null = день пропущен (нет записи в DaysTable).
  final List<DayLog?> slots;

  /// AVG по заполненным дням без срывов.
  final double avgScore;

  /// Кол-во существующих записей в DaysTable за неделю.
  final int honestDaysCount;

  /// Отклонение от dailyLimit в процентах. Отрицательное = потратил меньше бюджета.
  final double? deviationPercent;

  final Session session;

  const WeeklyReportData({
    required this.weekNumber,
    required this.weekStart,
    required this.weekEnd,
    required this.slots,
    required this.avgScore,
    required this.honestDaysCount,
    required this.deviationPercent,
    required this.session,
  });
}

class CheckAndGenerateWeeklyReportUseCase {
  final SessionRepository _sessionRepository;

  CheckAndGenerateWeeklyReportUseCase({
    required SessionRepository sessionRepository,
  }) : _sessionRepository = sessionRepository;

  Future<WeeklyReportData?> execute(Session session) async {
    if (session.phase != 1 || session.controlStartedAt == null) return null;

    final completedDays =
    await _sessionRepository.getCompletedControlDays(session.id);
    final count = completedDays.length;

    if (count == 0 || count % 7 != 0) return null;

    final currentWeek = count ~/ 7;
    final lastReviewed = session.lastReviewedControlWeek ?? 0;

    if (currentWeek <= lastReviewed) return null;

    final controlStart = DateTime(
      session.controlStartedAt!.year,
      session.controlStartedAt!.month,
      session.controlStartedAt!.day,
    );

    final weekStart = controlStart.add(Duration(days: (currentWeek - 1) * 7));
    final weekEnd = weekStart.add(const Duration(days: 6));

    final dayLogMap = <DateTime, DayLog>{};
    for (final d in completedDays) {
      final key = DateTime(d.date.year, d.date.month, d.date.day);
      dayLogMap[key] = d;
    }

    final slots = <DayLog?>[];
    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final log = dayLogMap[day];

      if (log == null) {
        slots.add(null);
        continue;
      }

      // День создан getOrCreateDayLog но без единого действия — пропуск.
      final hasClicks = log.isBrokenClicked ||
          log.isGoodBoyClicked ||
          await _sessionRepository.hasHabitClicksForDate(day);

      slots.add(hasClicks ? log : null);
    }

    final scoresMap = await _sessionRepository.getScoresPerDateRange(
        weekStart, weekEnd);

    // AVG: исключаем broken и пропущенные дни
    final validScores = <int>[];
    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final log = slots[i];
      if (log == null) continue;
      if (log.isBrokenClicked) continue;
      validScores.add(scoresMap[day] ?? 0);
    }

    final avgScore = validScores.isEmpty
        ? 0.0
        : validScores.fold(0, (a, b) => a + b) / validScores.length;

    final honestDaysCount = slots.where((s) => s != null).length;

    final dailyLimit = session.dailyLimit;
    final deviationPercent = (dailyLimit != null && dailyLimit > 0)
        ? ((avgScore - dailyLimit) / dailyLimit) * 100
        : null;

    return WeeklyReportData(
      weekNumber: currentWeek,
      weekStart: weekStart,
      weekEnd: weekEnd,
      slots: slots,
      avgScore: avgScore,
      honestDaysCount: honestDaysCount,
      deviationPercent: deviationPercent,
      session: session,
    );
  }
}