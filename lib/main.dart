import 'package:flutter/material.dart';
import 'package:dopamine_budget/data/db/app_database.dart';

import 'package:dopamine_budget/features/sessions/data/repositories/session_repository_impl.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/get_sessions_by_day_usecase.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/initialize_session_usecase.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/start_control_session_usecase.dart';
import 'package:dopamine_budget/features/sessions/presentation/state/sessions_notifier.dart';
import 'package:dopamine_budget/features/sessions/presentation/state/control_screen_notifier.dart';

import 'package:dopamine_budget/features/scoring/data/repositories/scoring_repository_impl.dart';
import 'package:dopamine_budget/features/scoring/presentation/state/scoring_notifier.dart';
import 'package:dopamine_budget/features/scoring/domain/usecases/calculate_score_usecase.dart';
import 'package:dopamine_budget/features/scoring/domain/usecases/get_current_dopamine_balance_usecase.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/verify_calibration_expiry_usecase.dart';

import 'package:dopamine_budget/features/actions/domain/usecases/add_action_usecase.dart';
import 'package:dopamine_budget/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:dopamine_budget/features/habits/presentation/state/habits_notifier.dart';

import 'package:dopamine_budget/presentation/root_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase.instance;

  // Сессии
  final sessionRepository = SessionRepositoryImpl(database);
  final initializeSessionUseCase = InitializeSessionUseCase(database);
  final startControlSessionUseCase = StartControlSessionUseCase(database);
  final getSessionsByDayUseCase = GetSessionsByDayUseCase(sessionRepository);

  final sessionsNotifier = SessionsNotifier(
    initializeSessionUseCase: initializeSessionUseCase,
    startControlSessionUseCase: startControlSessionUseCase,
  );

  // Привычки
  final habitRepository = HabitRepositoryImpl(database);
  final addActionUseCase = AddActionUseCase(database);

  final habitsNotifier = HabitsNotifier(
    habitRepository: habitRepository,
    addActionUseCase: addActionUseCase,
  );

  // Скоринг
  final scoringRepository = ScoringRepositoryImpl(database);
  final calculateScoreUseCase = CalculateScoreUseCase(scoringRepository);

  final verifyCalibrationExpiryUseCase = VerifyCalibrationExpiryUseCase(
    sessionRepository: sessionRepository,
    scoringRepository: scoringRepository,
  );

  final getDopamineBalanceUseCase = GetCurrentDopamineBalanceUseCase(
    sessionRepository: sessionRepository,
    scoringRepository: scoringRepository,
  );

  final scoringNotifier = ScoringNotifier(
    calculateScoreUseCase: calculateScoreUseCase,
    sessionRepository: sessionRepository,
    scoringRepository: scoringRepository,
    getSessionsUseCase: getSessionsByDayUseCase,
    verifyCalibrationExpiry: verifyCalibrationExpiryUseCase,
    getDopamineBalance: getDopamineBalanceUseCase,
  );

  // Экран контроля — сам грузит привычки через habitRepository
  final controlScreenNotifier = ControlScreenNotifier(
    sessionRepository: sessionRepository,
    getDopamineBalance: getDopamineBalanceUseCase,
    habitRepository: habitRepository,
  );

  runApp(MyApp(
    database: database,
    sessionsNotifier: sessionsNotifier,
    habitsNotifier: habitsNotifier,
    scoringNotifier: scoringNotifier,
    controlScreenNotifier: controlScreenNotifier,
  ));
}

class MyApp extends StatelessWidget {
  final AppDatabase database;
  final SessionsNotifier sessionsNotifier;
  final HabitsNotifier habitsNotifier;
  final ScoringNotifier scoringNotifier;
  final ControlScreenNotifier controlScreenNotifier;

  const MyApp({
    super.key,
    required this.database,
    required this.sessionsNotifier,
    required this.habitsNotifier,
    required this.scoringNotifier,
    required this.controlScreenNotifier,
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
        controlScreenNotifier: controlScreenNotifier,
      ),
    );
  }
}