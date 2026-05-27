import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Этот импорт обязателен! Файл .g.dart сгенерируется автоматически ниже
part 'app_database.g.dart';

// Описываем таблицу действий (кнопка нажата -> записали балл)
class ActionsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get habitType => text()();
  IntColumn get scoreValue => integer()();
  DateTimeColumn get timestamp => dateTime()();
}

// Описываем саму базу данных
@DriftDatabase(tables: [ActionsTable])
class AppDatabase extends _$AppDatabase {
  // Создаем тот самый Singleton (единственный экземпляр), который ищет main.dart
  static final AppDatabase instance = AppDatabase._internal();

  AppDatabase._internal() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}