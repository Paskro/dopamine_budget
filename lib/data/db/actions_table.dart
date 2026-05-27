import 'package:drift/drift.dart';

class ActionsTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get habitType => text()();
  // сигареты / фастфуд / соцсети

  IntColumn get scoreValue => integer()();

  DateTimeColumn get timestamp => dateTime()();
}