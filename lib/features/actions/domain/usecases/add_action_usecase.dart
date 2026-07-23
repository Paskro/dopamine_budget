import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import 'package:dopamine_budget/features/habits/domain/entities/habit.dart';
import 'package:dopamine_budget/core/utils/time_provider.dart';

class AddActionUseCase {
  final AppDatabase _db;
  final _uuid = const Uuid();

  AddActionUseCase(this._db);

  Future<void> execute(Habit habit) async {
    final sessionId = await _db.getActiveSessionId();
    if (sessionId == null) {
      throw StateError('Нет активной сессии для записи действия');
    }

    await _db.into(_db.habitLogsTable).insert(
      HabitLogsTableCompanion(
        id: Value(_uuid.v4()),
        habitId: Value(habit.id),
        sessionId: Value(sessionId),
        timestamp: Value(TimeProvider.now),
        updatedAt: Value(TimeProvider.now.toIso8601String()),
      ),
    );
  }
}