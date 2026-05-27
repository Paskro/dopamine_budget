import 'package:drift/drift.dart';

class SessionsTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get phase => integer()(); // 0 = stats (калибровка), 1 = control (контроль)
  RealColumn get avgScore => real().nullable()(); // Базовый лимит XP

  // === НОВЫЕ ПОЛЯ ДЛЯ ГИБКИХ НАСТРОЕК СЕЙЧАС И НА БУДУЩЕЕ ===

  // Нужно ли автоматически снижать лимит со временем
  BoolColumn get shouldDecrease => boolean().withDefault(const Constant(false))();

  // Процент снижения (например, 5.0)
  RealColumn get decreasePercentage => real().nullable()();

  // Интервал снижения ('week' или 'month')
  TextColumn get decreaseInterval => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}