import 'package:drift/drift.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';
import 'package:flutter/foundation.dart';

class InitializeSessionUseCase {
  final AppDatabase _db;

  InitializeSessionUseCase(this._db);

  Future<Session?> execute({bool forceRestart = false, int durationDays = 7}) async {
      try {
        final row = await (_db.select(_db.sessionsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
            .getSingleOrNull();
        print('RAW controlStartedAt=${row?.controlStartedAt}, phase=${row?.phase}, id=${row?.id}');
        if (!forceRestart) {
          // ФИКС: явный orderBy по createdAt DESC — без него порядок строк
          // не определён и .last может вернуть НЕ последнюю созданную сессию.
          // Это рассинхронизировало SessionsNotifier с getActiveSession()
          // в SessionRepositoryImpl, который уже использует orderBy DESC.
          final latestRow = await (_db.select(_db.sessionsTable)
                ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
                ..limit(1))
              .getSingleOrNull();

          if (latestRow != null) {
            return Session(
              id: latestRow.id,
              createdAt: latestRow.createdAt,
              phase: latestRow.phase,
              avgScore: latestRow.avgScore,
              shouldDecrease: latestRow.shouldDecrease,
              decreasePercentage: latestRow.decreasePercentage,
              decreaseIntervalDays: latestRow.decreaseIntervalDays,
              isReviewed: latestRow.isReviewed,
              calibrationDays: latestRow.calibrationDays,
              controlStartedAt: latestRow.controlStartedAt,
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

        final companion = SessionsTableCompanion(
          id: Value(newId),
          createdAt: Value(now),
          phase: const Value(0),
          avgScore: const Value(null),
          shouldDecrease: const Value(false),
          decreasePercentage: const Value(null),
          decreaseIntervalDays: const Value(null),
          calibrationDays: Value(durationDays),
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
          decreaseIntervalDays: null,
          calibrationDays: durationDays,
        );
      } catch (e) {
        print('Ошибка при инициализации сессии: $e');
        return null;
      }
    }
}