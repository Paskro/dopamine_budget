import 'package:drift/drift.dart';
import 'package:dopamine_budget/features/sessions/data/tables/sessions_table.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';

class SessionMapper {
  static Session fromDb(SessionsTableData data) {
    return Session(
      id: data.id,
      createdAt: data.createdAt,
      phase: data.phase,
      avgScore: data.avgScore,
      isReviewed: data.isReviewed,
      shouldDecrease: data.shouldDecrease,
      calibrationDays: data.calibrationDays,
      controlStartedAt: data.controlStartedAt,
      baseShrinkingLimit: data.baseShrinkingLimit,
      shrinkingStartedAt: data.shrinkingStartedAt,
      decreasePercentage: data.decreasePercentage,
      decreaseIntervalDays: data.decreaseIntervalDays,
      shrunkenLimit: data.shrunkenLimit,
    );
  }

  static SessionsTableCompanion toCompanion(Session session) {
    return SessionsTableCompanion.insert(
      id: session.id,
      createdAt: session.createdAt,
      phase: session.phase,
      avgScore: Value(session.avgScore),
      isReviewed: Value(session.isReviewed),
      shouldDecrease: Value(session.shouldDecrease),
      calibrationDays: Value(session.calibrationDays),
      controlStartedAt: Value(session.controlStartedAt),
      baseShrinkingLimit: Value(session.baseShrinkingLimit),
      shrinkingStartedAt: Value(session.shrinkingStartedAt),
      decreasePercentage: Value(session.decreasePercentage),
      decreaseIntervalDays: Value(session.decreaseIntervalDays),
      shrunkenLimit: Value(session.shrunkenLimit),
    );
  }
}