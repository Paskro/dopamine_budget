import 'package:flutter/foundation.dart';

@immutable
class ShrinkingPeriod {
  final String? id;
  final String sessionId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final double baseLimit;
  final double decreasePct;
  final int intervalDays;

  const ShrinkingPeriod({
    this.id,
    required this.sessionId,
    required this.startedAt,
    this.endedAt,
    required this.baseLimit,
    required this.decreasePct,
    required this.intervalDays,
  });
}