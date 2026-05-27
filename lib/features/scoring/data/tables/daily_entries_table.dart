import 'package:drift/drift.dart';

class DailyEntriesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionId => text()(); // Привязка к ядру Sessions
  DateTimeColumn get date => dateTime()();
  TextColumn get habitId => text()();
  IntColumn get count => integer()();
}