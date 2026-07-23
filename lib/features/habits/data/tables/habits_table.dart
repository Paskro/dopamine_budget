import 'package:drift/drift.dart';

class HabitsTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  IntColumn get scoreValue => integer()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class SessionHabitsTable extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  TextColumn get habitId => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [{sessionId, habitId}];
}