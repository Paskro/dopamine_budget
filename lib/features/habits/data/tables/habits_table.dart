import 'package:drift/drift.dart';

// Описываем, как таблица привычек будет выглядеть в SQL-базе данных
class HabitsTable extends Table {
  IntColumn get id => integer().autoIncrement()(); // Уникальный ID, увеличивается сам
  TextColumn get title => text()();               // Название привычки (текст)
  IntColumn get scoreValue => integer()();        // Баллы за неё (число)
}