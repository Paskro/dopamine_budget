import 'package:flutter/foundation.dart';

// lib/features/sessions/domain/entities/day_log.dart

@immutable
class DayLog {
  final int id;
  final DateTime date;     // DateTime внутри домена — маппер отсекает время
  final String sessionId;
  final bool isBrokenClicked;
  final bool isGoodBoyClicked;
  final String dayStatus;  // 'regular' | 'ideal' | 'almost_ideal'

  const DayLog({
    required this.id,
    required this.date,
    required this.sessionId,
    required this.isBrokenClicked,
    required this.isGoodBoyClicked,
    required this.dayStatus,
  });

  DayLog copyWith({
    int? id,
    DateTime? date,
    String? sessionId,
    bool? isBrokenClicked,
    bool? isGoodBoyClicked,
    String? dayStatus,
  }) {
    return DayLog(
      id: id ?? this.id,
      date: date ?? this.date,
      sessionId: sessionId ?? this.sessionId,
      isBrokenClicked: isBrokenClicked ?? this.isBrokenClicked,
      isGoodBoyClicked: isGoodBoyClicked ?? this.isGoodBoyClicked,
      dayStatus: dayStatus ?? this.dayStatus,
    );
  }
}