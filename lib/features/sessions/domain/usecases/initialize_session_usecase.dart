import 'package:drift/drift.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';

class InitializeSessionUseCase {
  final AppDatabase _db;

  InitializeSessionUseCase(this._db);

  Future<Session?> execute({bool forceRestart = false, int durationDays = 7}) async {
      try {
        if (!forceRestart) {
          final allSessions = await _db.select(_db.sessionsTable).get();

          if (allSessions.isNotEmpty) {
            final latestRow = allSessions.last;
            return Session(
              id: latestRow.id,
              createdAt: latestRow.createdAt,
              phase: latestRow.phase,
              avgScore: latestRow.avgScore,
              shouldDecrease: latestRow.shouldDecrease,
              decreasePercentage: latestRow.decreasePercentage?.toInt(),
              decreaseInterval: latestRow.decreaseInterval, // String? как есть
              isReviewed: latestRow.isReviewed,
              calibrationDays: latestRow.calibrationDays,
              );
          } else {
            return null;
          }
        }

        final now = DateTime.now();
        final year = now.year;
        final month = now.month.toString().padLeft(2, '0');
        final day = now.day.toString().padLeft(2, '0');
        final hour = now.hour.toString().padLeft(2, '0');
        final minute = now.minute.toString().padLeft(2, '0');

        final newId = 'S_$year$month$day\_$hour$minute';

        // ТЕПЕРЬ МЫ ЧЕСТНО ПИШЕМ СЮДА ПАРАМЕТР durationDays
        final companion = SessionsTableCompanion(
          id: Value(newId),
          createdAt: Value(now),
          phase: const Value(0),
          avgScore: const Value(null),
          shouldDecrease: const Value(false),
          decreasePercentage: const Value(null),
          decreaseInterval: const Value(null),
          calibrationDays: Value(durationDays), // <-- теперь в правильном поле
        );

        await _db.into(_db.sessionsTable).insert(companion);

        print('=== Новая фаза калибровки создана на $durationDays дней! ===');

        return Session(
          id: newId,
          createdAt: now,
          phase: 0,
          avgScore: null,
          shouldDecrease: false,
          decreasePercentage: null,
          decreaseInterval: null,
          calibrationDays: durationDays,
        );
      } catch (e) {
        print('Ошибка при инициализации сессии: $e');
        return null;
      }
    }
}