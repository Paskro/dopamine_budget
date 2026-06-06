import 'package:drift/drift.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import '../../domain/entities/session.dart';

class SessionMapper {
  /// Конвертируем данные из БД (Drift) в доменную модель Session
  static Session fromDb(SessionsTableData data) {
    return Session(
      id: data.id,
      createdAt: data.createdAt,
      phase: data.phase,
      avgScore: data.avgScore,
      shouldDecrease: data.shouldDecrease,
      decreasePercentage: data.decreasePercentage?.toInt(), // Из double? в int?
      decreaseInterval: data.decreaseInterval != null
          ? (double.tryParse(data.decreaseInterval!)?.toInt() ?? int.tryParse(data.decreaseInterval!))
          : null,
      isReviewed: data.isReviewed,
    );
  }

  /// Конвертируем доменную модель Session в формат Drift для базы данных
  static SessionsTableCompanion toDb(Session session) {
    return SessionsTableCompanion(
      id: Value(session.id),
      createdAt: Value(session.createdAt),
      phase: Value(session.phase),
      avgScore: Value(session.avgScore),
      shouldDecrease: Value(session.shouldDecrease),
      decreasePercentage: Value(session.decreasePercentage?.toDouble()), // Из int? в double?
      decreaseInterval: Value(session.decreaseInterval?.toString()),
      isReviewed: Value(session.isReviewed),
    );
  }
}