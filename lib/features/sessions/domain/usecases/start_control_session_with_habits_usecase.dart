import 'package:drift/drift.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';
import 'package:dopamine_budget/core/utils/time_provider.dart';

class StartControlSessionWithHabitsUseCase {
  final AppDatabase _db;

  StartControlSessionWithHabitsUseCase(this._db);

  Future<Session> execute({
    required double manualLimit,
    required Set<int> habitIds,
  }) async {
    final newId = TimeProvider.now.millisecondsSinceEpoch.toString();
    final now = TimeProvider.now;

    await _db.transaction(() async {
      await _db.into(_db.sessionsTable).insert(
        SessionsTableCompanion(
          id: Value(newId),
          createdAt: Value(now),
          phase: const Value(1),
          avgScore: Value(manualLimit),
          shouldDecrease: const Value(false),
          controlStartedAt: Value(now),
          isReviewed: const Value(true),
        ),
      );

      for (final habitId in habitIds) {
        await _db.into(_db.sessionHabitsTable).insert(
          SessionHabitsTableCompanion(
            sessionId: Value(newId),
            habitId: Value(habitId),
          ),
        );
      }
    });

    return Session(
      id: newId,
      createdAt: now,
      phase: 1,
      avgScore: manualLimit,
      shouldDecrease: false,
      controlStartedAt: now,
    );
  }
}