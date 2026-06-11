import '../entities/session.dart';
import '../entities/day_log.dart';

// lib/features/sessions/domain/repositories/session_repository.dart

abstract class SessionRepository {
  // === SESSIONS ===

  Future<void> addSession(Session session);
  Future<void> updateSession(Session session);
  Future<List<Session>> getSessionsByDay(DateTime date);

  /// Возвращает активную (последнюю) сессию или null
  Future<Session?> getActiveSession();

  /// Переводит сессию в фазу Контроля и сбрасывает флаг ознакомления
  Future<void> updateSessionToControl({required String sessionId});

  Future<int> getTotalScoreSpentByDay(DateTime date);
  Future<void> recordActionLog({
    required String habitId,
    required int scoreCost,
    required DateTime createdAt,
  });

  /// Баллы за каждый день начиная с даты старта сессии (maxDays дней)
  Future<List<double>> getScoresPerDaySince(DateTime startDate, int maxDays);

  /// Топ-1 привычка по количеству срабатываний за период
  Future<String?> getMostFrequentHabitSince(DateTime startDate);

  /// Баллы по каждой привычке за каждый день — ровно maxDays дней
  Future<List<Map<String, int>>> getScoresPerHabitPerDay(
      DateTime startDate, int maxDays);

  // === DAYS TABLE ===

  /// Возвращает запись дня по дате. Если записи нет — возвращает null.
  Future<DayLog?> getDayLog(DateTime date);

  /// Создаёт запись дня если её ещё нет (идемпотентно).
  Future<DayLog> getOrCreateDayLog({
    required DateTime date,
    required String sessionId,
  });

  /// Фиксирует срыв: isBrokenClicked = true.
  /// Вызывается только из домена — UI не трогает флаги напрямую.
  Future<void> markDayAsBroken(DateTime date);

  /// Фиксирует «Я сегодня молодец»: isGoodBoyClicked = true, dayStatus = 'ideal'.
  Future<void> markDayAsGoodBoy(DateTime date);

  /// Атомарная транзакция: записывает клик привычки + деградирует статус
  /// ideal → almost_ideal если условие сошлось.
  /// Вся логика проверки — внутри транзакции на уровне БД.
  Future<void> logHabitClickWithStatusCheck({
    required String habitId,
    required int scoreCost,
    required DateTime timestamp,
  });
}