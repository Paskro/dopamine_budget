// ЗАМЕНИТЬ весь файл:
import 'package:flutter/foundation.dart';

@immutable
class DayLog {
  final DateTime date;
  final String sessionId;

  @Deprecated(
    "Источник правды — dayStatus == 'broken'. Поле оставлено только для "
        "обратной совместимости старых записей, не использовать в новой логике.",
  )
  final bool isBrokenClicked;

  final bool isGoodBoyClicked;
  final String dayStatus;
  final bool isWeeklyReportReviewed;

  const DayLog({
    required this.date,
    required this.sessionId,
    required this.isBrokenClicked,
    required this.isGoodBoyClicked,
    required this.dayStatus,
    required this.isWeeklyReportReviewed,
  });

  bool get isBroken => dayStatus == 'broken';

  DayLog copyWith({
    DateTime? date,
    String? sessionId,
    bool? isBrokenClicked,
    bool? isGoodBoyClicked,
    String? dayStatus,
    bool? isWeeklyReportReviewed,
  }) {
    return DayLog(
      date: date ?? this.date,
      sessionId: sessionId ?? this.sessionId,
      isBrokenClicked: isBrokenClicked ?? this.isBrokenClicked,
      isGoodBoyClicked: isGoodBoyClicked ?? this.isGoodBoyClicked,
      dayStatus: dayStatus ?? this.dayStatus,
      isWeeklyReportReviewed: isWeeklyReportReviewed ?? this.isWeeklyReportReviewed,
    );
  }
}