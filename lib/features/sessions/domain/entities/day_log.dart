import 'package:flutter/foundation.dart';

@immutable
class DayLog {
  final int id;
  final DateTime date;     // DateTime внутри домена — маппер отсекает время
  final String sessionId;

  @Deprecated(
    "Источник правды — dayStatus == 'broken'. Поле оставлено только для "
        "обратной совместимости старых записей, не использовать в новой логике.",
  )
  final bool isBrokenClicked;

  final bool isGoodBoyClicked;
  final String dayStatus;  // 'regular' | 'ideal' | 'almost_ideal' | 'broken' (терминальный)
  final bool isWeeklyReportReviewed;

  const DayLog({
    required this.id,
    required this.date,
    required this.sessionId,
    required this.isBrokenClicked,
    required this.isGoodBoyClicked,
    required this.dayStatus,
    required this.isWeeklyReportReviewed,
  });

  /// Единственный корректный способ проверки срыва дня.
  bool get isBroken => dayStatus == 'broken';

  DayLog copyWith({
    int? id,
    DateTime? date,
    String? sessionId,
    bool? isBrokenClicked,
    bool? isGoodBoyClicked,
    String? dayStatus,
    bool? isWeeklyReportReviewed,
  }) {
    return DayLog(
      id: id ?? this.id,
      date: date ?? this.date,
      sessionId: sessionId ?? this.sessionId,
      isBrokenClicked: isBrokenClicked ?? this.isBrokenClicked,
      isGoodBoyClicked: isGoodBoyClicked ?? this.isGoodBoyClicked,
      dayStatus: dayStatus ?? this.dayStatus,
      isWeeklyReportReviewed: isWeeklyReportReviewed ?? this.isWeeklyReportReviewed,
    );
  }
}