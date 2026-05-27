import 'package:drift/drift.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import 'package:dopamine_budget/features/habits/domain/entities/habit.dart';
import 'package:dopamine_budget/features/habits/domain/repositories/habit_repository.dart';

class HabitRepositoryImpl implements HabitRepository {
  // Подключаем базу данных
  final AppDatabase _db;

  HabitRepositoryImpl(this._db);

  @override
  Future<List<Habit>> getHabits() async {
    // Получаем все строчки из таблицы habitsTable
    final rows = await _db.select(_db.habitsTable).get();

    // Превращаем их в список привычек для нашего интерфейса
    return rows.map<Habit>((row) {
      return Habit(
        id: row.id.toString(),
        title: row.title,
        scoreValue: row.scoreValue, // Получаем баллы из базы данных
      );
    }).toList();
  }

  @override
  Future<void> saveHabit(Habit habit) async {
    // Проверяем: если ID пустой, равен "0" или содержит временный/случайный маркер новой привычки
    // (Например, если на UI при создании новой привычки ты передаешь id: "" или id: "0")
    final isNewHabit = habit.id.isEmpty || habit.id == '0' || habit.id.length > 5;

    final companion = HabitsTableCompanion(
      // Если привычка новая — пишем Value.absent(), и Drift сам выдаст ей красивый ID (1, 2, 3...)
      // Если старая — парсим и сохраняем её родной ID
      id: isNewHabit ? const Value.absent() : Value(int.parse(habit.id)),
      title: Value(habit.title),
      scoreValue: Value(habit.scoreValue),
    );

    // Insert or Update
    await _db.into(_db.habitsTable).insertOnConflictUpdate(companion);
  }

  @override
  Future<void> deleteHabit(String id) async {
    // Удаляем из базы по ID
    await (_db.delete(_db.habitsTable)
          ..where((t) => t.id.equals(int.parse(id))))
        .go();
  }

  @override
  Future<void> addHabit(dynamic habit) async {
    if (habit is Habit) {
      await saveHabit(habit);
    }
  }

  @override
  Future<void> updateHabit(dynamic habit) async {
    if (habit is Habit) {
      await saveHabit(habit);
    }
  }
}