import 'package:drift/drift.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/day_log.dart';

// lib/features/sessions/data/mappers/day_log_mapper.dart
// intl убран — используем встроенный String.padLeft для форматирования даты

class DayLogMapper {
  /// DB row → Domain entity
  static DayLog fromDb(DaysTableData data) {
    return DayLog(
      id: data.id,
      date: DateTime.parse(data.date),
      sessionId: data.sessionId,
      // ignore: deprecated_member_use_from_same_package
      isBrokenClicked: data.isBrokenClicked,
      isGoodBoyClicked: data.isGoodBoyClicked,
      dayStatus: data.dayStatus,
    );
  }

  /// Domain entity → Companion для INSERT
  static DaysTableCompanion toInsertCompanion(DayLog dayLog) {
    return DaysTableCompanion.insert(
      date: dateToString(dayLog.date),
      sessionId: dayLog.sessionId,
      isBrokenClicked: Value(dayLog.isBrokenClicked),
      isGoodBoyClicked: Value(dayLog.isGoodBoyClicked),
      dayStatus: Value(dayLog.dayStatus),
    );
  }

  /// Domain entity → Companion для UPDATE (id обязателен)
  static DaysTableCompanion toUpdateCompanion(DayLog dayLog) {
    return DaysTableCompanion(
      id: Value(dayLog.id),
      date: Value(dateToString(dayLog.date)),
      sessionId: Value(dayLog.sessionId),
      isBrokenClicked: Value(dayLog.isBrokenClicked),
      isGoodBoyClicked: Value(dayLog.isGoodBoyClicked),
      dayStatus: Value(dayLog.dayStatus),
    );
  }

  /// DateTime → строка 'yyyy-MM-dd' без зависимости от intl
  static String dateToString(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}