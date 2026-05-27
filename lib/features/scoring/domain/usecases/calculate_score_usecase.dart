import 'package:drift/drift.dart';
import 'package:dopamine_budget/data/db/app_database.dart';

class CalculateScoreUseCase {
  final AppDatabase _db;

  CalculateScoreUseCase(this._db);

  Future<int> call() async {
    const int startBudget = 100; // Стартовый бюджет

    try {
      // Читаем честные логи срывов из правильной таблицы действий
      final allActions = await _db.select(_db.actionsTable).get();

      final now = DateTime.now();
      final todayActions = allActions.where((action) {
        final date = action.timestamp;
        return date.year == now.year &&
               date.month == now.month &&
               date.day == now.day;
      });

      int totalPenalty = 0;
      for (var action in todayActions) {
        totalPenalty += action.scoreValue; // Суммируем штрафы
      }

      return startBudget - totalPenalty;
    } catch (e) {
      print('Ошибка при расчете баланса в UseCase: $e');
      return startBudget;
    }
  }
}