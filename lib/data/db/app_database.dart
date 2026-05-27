import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../features/sessions/data/tables/sessions_table.dart';
import '../../features/actions/data/tables/actions_table.dart';
// Импортируем нашу новую таблицу
import '../../features/habits/data/tables/habits_table.dart';

part 'app_database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'dopamine.db'));
    return NativeDatabase(file);
  });
}

@DriftDatabase(
  tables: [
    SessionsTable,
    ActionsTable,
    HabitsTable, // <-- Добавили таблицу в список таблиц БД
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}