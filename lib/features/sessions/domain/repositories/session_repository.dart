import '../entities/session.dart';
import '../entities/day_log.dart';
import '../entities/shrinking_period.dart';
import '../entities/day_stats.dart';
import 'package:drift/drift.dart';

abstract class SessionRepository {
  // === SESSIONS (legacy Future API) ===

  Future<void> addSession(Session session);
  Future<void> updateSession(Session session);
  Future<List<Session>> getSessionsByDay(DateTime date);
  Future<Session?> getActiveSession();
  Future<void> updateSessionToControl({required String sessionId});
  Future<List<DayLog>> getCompletedControlDays(String sessionId);
  Future<bool> hasHabitClicksForDate(DateTime date);
  Future<Map<DateTime, int>> getScoresPerDateRange(
      DateTime from, DateTime to);
  Future<bool> isShrinkingReportReviewed(String sessionId, DateTime periodStart);
  Future<void> markShrinkingReportReviewed(String sessionId, DateTime periodStart);
  Future<int> getShrinkingPeriodsCount(String sessionId);
  Future<List<DayStats>> getDayStatsForRange(DateTime from, DateTime to);

  Future<int> getTotalScoreSpentByDay(DateTime date);
  Future<void> recordActionLog({
    required String habitId,
    required int scoreCost,
    required DateTime createdAt,
  });
  Future<ShrinkingPeriod?> getActiveShrinkingPeriod(String sessionId);
  Future<void> insertShrinkingPeriod(ShrinkingPeriod period);
  Future<void> closeShrinkingPeriod({
    required int periodId,
    required String endedAt,
    required double shrunkenLimit,
  });

  Future<List<double>> getScoresPerDaySince(DateTime startDate, int maxDays);
  Future<String?> getMostFrequentHabitSince(DateTime startDate);
  Future<List<Map<String, int>>> getScoresPerHabitPerDay(
      DateTime startDate, int maxDays);

  // === DAYS TABLE (legacy Future API) ===

  Future<DayLog?> getDayLog(DateTime date);
  Future<DayLog> getOrCreateDayLog({
    required DateTime date,
    required String sessionId,
  });

  /// Безусловно помечает день как 'broken'. Терминальный статус — после
  /// вызова дальнейшие переходы dayStatus для этого дня запрещены
  /// (см. markDayAsGoodBoy, logHabitClickWithStatusCheck).
  Future<void> markDayAsBroken(DateTime date);

  /// Помечает день как 'ideal'. Бросает [StateError], если день уже
  /// зафиксирован как 'broken' — вызывающая сторона обязана обработать
  /// исключение (см. ControlScreenNotifier.confirmGoodBoy).
  Future<void> markDayAsGoodBoy(DateTime date);

  /// Записывает клик по привычке и при необходимости деградирует
  /// dayStatus 'ideal' → 'almost_ideal' в единой транзакции.
  /// Бросает [StateError], если день уже зафиксирован как 'broken'.
  Future<void> logHabitClickWithStatusCheck({
    required String habitId,
    required int scoreCost,
    required DateTime timestamp,
  });

  // ===========================================================================
  // STREAM API — Single Source of Truth.
  // ===========================================================================

  Stream<Session?> watchActiveSession();
  Stream<DayLog?> watchDayLog(DateTime date);
  Stream<int> watchScoreForDay(DateTime start, DateTime endExclusive);
  Future<void> updateSessionPhase(String sessionId, int newPhase);
  Future<void> deleteSession(String sessionId);
  Future<List<Session>> getPastSessions();
  Future<void> updateShrinkingState({
    Value<double?> baseShrinkingLimit = const Value.absent(),
    Value<DateTime?> shrinkingStartedAt = const Value.absent(),
  });
  Future<void> markWeeklyReportAsReviewed(DateTime date);
}