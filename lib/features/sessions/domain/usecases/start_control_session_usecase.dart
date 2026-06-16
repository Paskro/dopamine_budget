import 'package:drift/drift.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';
import 'package:dopamine_budget/core/utils/time_provider.dart';

class StartControlSessionUseCase {
  final AppDatabase _db;

  StartControlSessionUseCase(this._db);

  Future<Session> execute({
    required double manualLimit,
    required bool shouldDecrease,
    double? decreasePercentage,
    String? decreaseInterval,
  }) async {
    try {
      final newId = TimeProvider.now.millisecondsSinceEpoch.toString();
      final now = TimeProvider.now;

      final companion = SessionsTableCompanion(
        id: Value(newId),
        createdAt: Value(now),
        phase: const Value(1),
        avgScore: Value(manualLimit),
        shouldDecrease: Value(shouldDecrease),
        decreasePercentage: Value(decreasePercentage),
        decreaseInterval: Value(decreaseInterval),
        // Для ручного контроля controlStartedAt = момент создания сессии
        controlStartedAt: Value(now),
      );

      await _db.into(_db.sessionsTable).insert(companion);

      return Session(
        id: newId,
        createdAt: now,
        phase: 1,
        avgScore: manualLimit,
        shouldDecrease: shouldDecrease,
        decreasePercentage: decreasePercentage?.toInt(),
        decreaseInterval: decreaseInterval,
        controlStartedAt: now,
      );
    } catch (e) {
      print('Ошибка при создании сессии контроля: $e');
      return Session(
        id: '0',
        createdAt: TimeProvider.now,
        phase: 1,
        avgScore: 100,
        shouldDecrease: false,
        controlStartedAt: TimeProvider.now,
      );
    }
  }
}