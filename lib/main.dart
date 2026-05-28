import 'package:flutter/material.dart';
import 'package:dopamine_budget/data/db/app_database.dart';

// Импорты фичи Сессий
import 'package:dopamine_budget/features/sessions/data/repositories/session_repository_impl.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/add_session_usecase.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/get_sessions_by_day_usecase.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/initialize_session_usecase.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/start_control_session_usecase.dart';
import 'package:dopamine_budget/features/sessions/presentation/state/sessions_notifier.dart';
// Импорты фичи Скоринга
import 'package:dopamine_budget/features/scoring/data/repositories/scoring_repository_impl.dart';
import 'package:dopamine_budget/features/scoring/domain/repositories/scoring_repository.dart';
import 'package:dopamine_budget/features/scoring/presentation/state/scoring_notifier.dart';
import 'package:dopamine_budget/features/scoring/domain/usecases/calculate_score_usecase.dart';

// Импорты фичи Привычек
import 'package:dopamine_budget/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:dopamine_budget/features/habits/domain/usecases/get_habits_usecase.dart';
import 'package:dopamine_budget/features/habits/domain/usecases/add_habit_usecase.dart';
import 'package:dopamine_budget/features/habits/domain/usecases/update_habit_use_case.dart';
import 'package:dopamine_budget/features/habits/domain/usecases/delete_habit_use_case.dart';
import 'package:dopamine_budget/features/habits/presentation/state/habits_notifier.dart';
import 'package:dopamine_budget/features/habits/presentation/pages/habits_page.dart';

// Импорты Действий и Входа в приложение
import 'package:dopamine_budget/features/actions/domain/usecases/add_action_usecase.dart';
import 'package:dopamine_budget/presentation/root_gate.dart';

// Импорты страниц
import 'package:dopamine_budget/features/scoring/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Создаем ОДИН экземпляр SQL базы данных
  final database = AppDatabase();

  // 2. Настраиваем фичу Сессий
    final sessionRepository = SessionRepositoryImpl(database); // Создаём один раз для всех
    final initializeSessionUseCase = InitializeSessionUseCase(database);
    final startControlSessionUseCase = StartControlSessionUseCase(database);
    final getSessionsByDayUseCase = GetSessionsByDayUseCase(sessionRepository);

    final sessionsNotifier = SessionsNotifier(
      initializeSessionUseCase: initializeSessionUseCase,
      startControlSessionUseCase: startControlSessionUseCase,
    );

  // 3. Настраиваем фичу Привычек
  final habitRepository = HabitRepositoryImpl(database);
  final getHabitsUseCase = GetHabitsUseCase(habitRepository);
  final addHabitUseCase = AddHabitUseCase(habitRepository);
  final updateHabitUseCase = UpdateHabitUseCase(habitRepository);
  final deleteHabitUseCase = DeleteHabitUseCase(habitRepository);

  final habitsNotifier = HabitsNotifier(
    getHabitsUseCase: getHabitsUseCase,
    addHabitUseCase: addHabitUseCase,
    updateHabitUseCase: updateHabitUseCase,
    deleteHabitUseCase: deleteHabitUseCase,
  );

  // 4. Настраиваем фичу Скоринга
    final scoringRepository = ScoringRepositoryImpl(database);
    final calculateScoreUseCase = CalculateScoreUseCase(scoringRepository);

    final scoringNotifier = ScoringNotifier(
      calculateScoreUseCase: calculateScoreUseCase,
      sessionRepository: sessionRepository,
      getSessionsUseCase: getSessionsByDayUseCase, // Передаем обязательный юзкейс
    );

    // Старые UseCase для совместимости
    final addSessionUseCase = AddSessionUseCase(sessionRepository);
    final addActionUseCase = AddActionUseCase(database);

  // 5. Запускаем приложение
  runApp(MyApp(
    database: database,
    sessionsNotifier: sessionsNotifier,
    habitsNotifier: habitsNotifier,
    scoringNotifier: scoringNotifier,
  ));
}

class MyApp extends StatelessWidget {
  final AppDatabase database;
  final SessionsNotifier sessionsNotifier;
  final HabitsNotifier habitsNotifier;
  final ScoringNotifier scoringNotifier;

  const MyApp({
    super.key,
    required this.database,
    required this.sessionsNotifier,
    required this.habitsNotifier,
    required this.scoringNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dopamine Budget',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: RootGate(
        database: database,
        sessionsNotifier: sessionsNotifier,
        habitsNotifier: habitsNotifier,
        scoringNotifier: scoringNotifier,
      ),
    );
  }
}

