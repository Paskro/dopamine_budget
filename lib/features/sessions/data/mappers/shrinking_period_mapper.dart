import 'package:dopamine_budget/data/db/app_database.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/shrinking_period.dart';
import 'package:drift/drift.dart';

class ShrinkingPeriodMapper {
  static ShrinkingPeriod fromDb(ShrinkingPeriodsTableData row) {
    return ShrinkingPeriod(
      id: row.id,
      sessionId: row.sessionId,
      startedAt: DateTime.parse(row.startedAt),
      endedAt: row.endedAt != null ? DateTime.parse(row.endedAt!) : null,
      baseLimit: row.baseLimit,
      decreasePct: row.decreasePct,
      intervalDays: row.intervalDays,
    );
  }

  static ShrinkingPeriodsTableCompanion toCompanion(ShrinkingPeriod p) {
    return ShrinkingPeriodsTableCompanion.insert(
      sessionId: p.sessionId,
      startedAt: _fmt(p.startedAt),
      endedAt: Value(p.endedAt != null ? _fmt(p.endedAt!) : null),
      baseLimit: p.baseLimit,
      decreasePct: p.decreasePct,
      intervalDays: p.intervalDays,
    );
  }

  static String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';
}