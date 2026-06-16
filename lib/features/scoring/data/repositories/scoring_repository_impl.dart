import 'package:drift/drift.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import '../../domain/repositories/scoring_repository.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';

class ScoringRepositoryImpl implements ScoringRepository {
  final AppDatabase _db;

  ScoringRepositoryImpl(this._db);

  @override
  Future<void> saveAction({
    required String habitType,
    required int scoreValue,
    required DateTime timestamp,
  }) async {
    await _db.into(_db.actionsTable).insert(
          ActionsTableCompanion.insert(
            habitType: habitType,
            scoreValue: scoreValue,
            timestamp: timestamp,
          ),
        );
  }

  @override
  Future<int> getScoreForDay(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));

    final query = _db.selectOnly(_db.actionsTable)
      ..addColumns([_db.actionsTable.scoreValue.sum()])
      ..where(_db.actionsTable.timestamp.isBetweenValues(startOfDay, endOfDay));

    final row = await query.getSingle();
    return row.read(_db.actionsTable.scoreValue.sum()) ?? 0;
  }

  @override
  Future<Map<String, int>> getHabitClicksForDay(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));

    final query = _db.select(_db.actionsTable)
      ..where((tbl) => tbl.timestamp.isBetweenValues(startOfDay, endOfDay));

    final rows = await query.get();

    final Map<String, int> result = {};
    for (final row in rows) {
      final key = row.habitType.toString();
      result[key] = (result[key] ?? 0) + 1;
    }

    return result;
  }

  // ==========================================
  // ВЫБОРКА УНИКАЛЬНЫХ КАЛЕНДАРНЫХ ДНЕЙ
  // ==========================================
  @override
  Future<List<DateTime>> getUniqueRecordedDays() async {
    try {
      // Используем функцию SQLite 'date', чтобы отсечь время (оставить YYYY-MM-DD)
      final dateFunction = CustomExpression<String>(
        "date(timestamp)"
      );

      // Строим запрос: берем только эту вычисляемую колонку дат
      final query = _db.selectOnly(_db.actionsTable)
        ..addColumns([dateFunction])
        ..groupBy([dateFunction]); // Группируем, чтобы исключить дубли

      final rows = await query.get();

      // Маппим строки обратно в объекты DateTime
      final List<DateTime> uniqueDays = rows.map((row) {
        final dateString = row.read(dateFunction);
        return DateTime.parse(dateString!);
      }).toList();

      // Сортируем даты от старых к новым (для порядка)
      uniqueDays.sort((a, b) => a.compareTo(b));
      return uniqueDays;

    } catch (e) {
      print('Ошибка при выборке уникальных дней в репозитории: $e');
      return [];
    }
  }
  @override
    Future<int> getSpentScoreByDay(DateTime date) async {
      return await getScoreForDay(date); // логика уже есть в getScoreForDay
    }

    @override
    Future<Session?> getActiveSession() async {
      // ScoringRepository не работает с сессиями напрямую —
      // делегируем через SessionRepositoryImpl или возвращаем null
      return null;
    }

    @override
    Future<int> getTotalScoreCostForDate(DateTime date) async {
      return await getScoreForDay(date); // та же логика
    }

    @override
    Future<void> updateSessionToControl({required String sessionId}) async {
      await (_db.update(_db.sessionsTable)
            ..where((t) => t.id.equals(sessionId)))
          .write(
        SessionsTableCompanion(
          phase: const Value(1),
          isReviewed: const Value(false), // false = пользователь ещё не ознакомился → триггер показа CalibrationResultPage
        ),
      );
    }
}