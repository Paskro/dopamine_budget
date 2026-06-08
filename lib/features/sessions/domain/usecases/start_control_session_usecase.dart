import 'package:drift/drift.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';

class StartControlSessionUseCase {
  final AppDatabase _db;

  StartControlSessionUseCase(this._db);

  // Принимаем ручной лимит и все настройки автоснижения бюджета
  Future<Session> execute({
    required double manualLimit,
    required bool shouldDecrease,
    double? decreasePercentage,
    String? decreaseInterval,
  }) async {
    try {
      final newId = DateTime.now().millisecondsSinceEpoch.toString();
      final now = DateTime.now();

      final companion = SessionsTableCompanion(
        id: Value(newId),
        createdAt: Value(now),
        phase: const Value(1), // 1 = Фаза Контроля
        avgScore: Value(manualLimit),
        shouldDecrease: Value(shouldDecrease),
        decreasePercentage: Value(decreasePercentage),
        decreaseInterval: Value(decreaseInterval),
      );

      // Сохраняем настройки в SQL
      await _db.into(_db.sessionsTable).insert(companion);

      print('=== Создана сессия КОНТРОЛЯ ===');
      print('Лимит: $manualLimit XP, Снижение: $shouldDecrease, %: $decreasePercentage, Интервал: $decreaseInterval');

      return Session(
        id: newId,
        createdAt: now,
        phase: 1,
        avgScore: manualLimit,
        shouldDecrease: shouldDecrease,
        decreasePercentage: decreasePercentage?.toInt(),
        decreaseInterval: decreaseInterval, // String? как есть
      );
    } catch (e) {
      print('Ошибка при создании сессии контроля: $e');
      return Session(
        id: '0',
        createdAt: DateTime.now(),
        phase: 1,
        avgScore: 100,
        shouldDecrease: false,
      );
    }
  }
}