// ЗАМЕНИТЬ весь файл:
import 'package:drift/drift.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/day_log.dart';
import 'package:dopamine_budget/core/utils/time_provider.dart';

class DayLogMapper {
  static DayLog fromDb(DaysTableData data) {
    return DayLog(
      date: DateTime.parse(data.date),
      sessionId: data.sessionId,
      // ignore: deprecated_member_use_from_same_package
      isBrokenClicked: data.isBrokenClicked,
      isGoodBoyClicked: data.isGoodBoyClicked,
      dayStatus: data.dayStatus,
      isWeeklyReportReviewed: data.isWeeklyReportReviewed,
    );
  }

  static DaysTableCompanion toInsertCompanion(DayLog dayLog) {
    return DaysTableCompanion.insert(
      date: dateToString(dayLog.date),
      sessionId: dayLog.sessionId,
      isBrokenClicked: Value(dayLog.isBrokenClicked),
      isGoodBoyClicked: Value(dayLog.isGoodBoyClicked),
      dayStatus: Value(dayLog.dayStatus),
      isWeeklyReportReviewed: Value(dayLog.isWeeklyReportReviewed),
      updatedAt: TimeProvider.now.toIso8601String(),
    );
  }

  static DaysTableCompanion toUpdateCompanion(DayLog dayLog) {
    return DaysTableCompanion(
      date: Value(dateToString(dayLog.date)),
      sessionId: Value(dayLog.sessionId),
      isBrokenClicked: Value(dayLog.isBrokenClicked),
      isGoodBoyClicked: Value(dayLog.isGoodBoyClicked),
      dayStatus: Value(dayLog.dayStatus),
      isWeeklyReportReviewed: Value(dayLog.isWeeklyReportReviewed),
      updatedAt: Value(TimeProvider.now.toIso8601String()),
    );
  }

  static String dateToString(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}