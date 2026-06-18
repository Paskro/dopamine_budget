import 'package:drift/drift.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import 'package:dopamine_budget/features/habits/domain/entities/habit.dart';
import 'package:dopamine_budget/core/utils/time_provider.dart';

class AddActionUseCase {
  final AppDatabase _db;

  AddActionUseCase(this._db);

  Future<void> execute(Habit habit) async {
    final sessionId = await _db.getActiveSessionId();
    if (sessionId == null) {
      throw StateError('Нет активной сессии для записи действия');
    }

    final companion = HabitLogsTableCompanion(
      habitId: Value(int.parse(habit.id)), // ASSUMPTION: habit.id — int. ПРОВЕРИТЬ habit.dart перед запуском
      sessionId: Value(sessionId),
      timestamp: Value(TimeProvider.now),
    );

    await _db.into(_db.habitLogsTable).insert(companion);
  }
}