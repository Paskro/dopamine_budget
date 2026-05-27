import 'package:drift/drift.dart';

class ActionsTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get habitType => text()(); // cigarettes / food / social

  IntColumn get scoreValue => integer()();

  DateTimeColumn get timestamp => dateTime()();
}