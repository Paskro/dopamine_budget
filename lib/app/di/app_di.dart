import 'package:dopamine_budget/data/db/app_database.dart'; // Путь к твоей БД
import 'sessions_di.dart';
import 'scoring_di.dart';

class AppDI {
  late final SessionsDI sessions;
  late final ScoringDI scoring;

  AppDI() {
    // 1. Создаем один общий экземпляр базы данных
    final db = AppDatabase();

    // 2. Передаем БД в SessionsDI и сразу сохраняем в переменную класса
    sessions = SessionsDI(db);

    // 3. Передаем базу и UseCase из сессий в ScoringDI
    scoring = ScoringDI(db, sessions);
  }
}