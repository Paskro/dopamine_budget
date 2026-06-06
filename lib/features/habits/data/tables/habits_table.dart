import 'package:drift/drift.dart';

// Описываем, как таблица привычек будет выглядеть в SQL-базе данных
class HabitsTable extends Table {
  IntColumn get id => integer().autoIncrement()(); // Уникальный ID, увеличивается сам
  TextColumn get title => text()();               // Название привычки (текст)
  IntColumn get scoreValue => integer()();        // Баллы за неё (число)
}

// Новая связующая таблица для чекбоксов (Выбранные привычки внутри сессии)
class SessionHabitsTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  // ID сессии из SessionsTable
  TextColumn get sessionId => text()();

  // ID привычки из HabitsTable
  IntColumn get habitId => integer()();

  // Добавим уникальный индекс, чтобы одна и та же привычка не привязалась к сессии дважды
  @override
  List<Set<Column>> get uniqueKeys => [
        {sessionId, habitId}
      ];
}