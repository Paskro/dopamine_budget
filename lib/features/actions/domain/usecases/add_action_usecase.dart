import 'package:drift/drift.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import 'package:dopamine_budget/features/habits/domain/entities/habit.dart';
import 'package:dopamine_budget/core/utils/time_provider.dart'; // Добавлен правильный провайдер времени

class AddActionUseCase {
  final AppDatabase _db;

  AddActionUseCase(this._db);

  Future<void> execute(Habit habit) async {
    // Формируем запись для таблицы actionsTable
    final companion = ActionsTableCompanion(
      // id база данных сгенерирует сама (autoIncrement)
      habitType: Value(habit.title), // Сохраняем имя привычки (например, "Сигареты")
      scoreValue: Value(habit.scoreValue), // Сохраняем стоимость штрафа (теперь пишется реальное число!)
      timestamp: Value(TimeProvider.now), // ИСПРАВЛЕНО: строго через TimeProvider.now вместо DateTime.now()
    );

    // Записываем лог в SQL «намертво»
    await _db.into(_db.actionsTable).insert(companion);
  }
}