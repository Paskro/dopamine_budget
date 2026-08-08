import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';
import 'package:dopamine_budget/core/utils/time_provider.dart';
import 'package:dopamine_budget/core/sync/sync_service.dart';

class StartControlSessionWithHabitsUseCase {
  final AppDatabase _db;
  final SyncService? _sync;
  final _uuid = const Uuid();

  StartControlSessionWithHabitsUseCase(this._db, {SyncService? sync}) : _sync = sync;

  Future<Session> execute({
    required double manualLimit,
    required Set<String> habitIds,
  }) async {
    final newId = _uuid.v4();
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
          updatedAt: Value(now.toIso8601String()),
        ),
      );

      for (final habitId in habitIds) {
        await _db.into(_db.sessionHabitsTable).insert(
          SessionHabitsTableCompanion(
            id: Value(_uuid.v4()),
            sessionId: Value(newId),
            habitId: Value(habitId),
            updatedAt: Value(now.toIso8601String()),
          ),
        );
      }
    });

    _sync?.pushSessions().catchError((_) {});
    _sync?.pushSessionHabits().catchError((_) {});

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