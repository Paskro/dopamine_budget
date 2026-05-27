import 'package:drift/drift.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';

class InitializeSessionUseCase {
  final AppDatabase _db;

  InitializeSessionUseCase(this._db);

  // forceRestart — для сброса сессии
  // durationDays — для гибкой калибровки (по умолчанию 7 дней)
  Future<Session?> execute({bool forceRestart = false, int durationDays = 7}) async {
      try {
        // 1. Если это НЕ принудительный сброс, проверяем, есть ли что-то в базе
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
              decreasePercentage: latestRow.decreasePercentage,
              decreaseInterval: latestRow.decreaseInterval,
            );
          } else {
            // ЕСЛИ В БАЗЕ ПУСТО — возвращаем null, чтобы включился Онбординг!
            return null;
          }
        }

        // 2. Сюда мы попадем ТОЛЬКО если forceRestart == true (пользователь нажал кнопку на онбординге)
        final newId = DateTime.now().millisecondsSinceEpoch.toString();
        final now = DateTime.now();

        final companion = SessionsTableCompanion(
          id: Value(newId),
          createdAt: Value(now),
          phase: const Value(0),
          avgScore: const Value(null),
          shouldDecrease: const Value(false),
          decreasePercentage: const Value(null),
          decreaseInterval: const Value(null),
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
        );
      } catch (e) {
        print('Ошибка при инициализации сессии: $e');
        return null;
      }
    }
}