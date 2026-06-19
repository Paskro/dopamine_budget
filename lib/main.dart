import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
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
import 'package:dopamine_budget/features/sessions/domain/usecases/check_and_generate_weekly_report_usecase.dart';

import 'package:dopamine_budget/features/actions/domain/usecases/add_action_usecase.dart';
import 'package:dopamine_budget/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:dopamine_budget/features/habits/presentation/state/habits_notifier.dart';

import 'package:dopamine_budget/presentation/root_gate.dart';
import 'package:dopamine_budget/core/utils/time_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru', null);
  await TimeProvider.restore();

  final database = AppDatabase.instance;



  // Репозитории
  final sessionRepository = SessionRepositoryImpl(database);
  final habitRepository = HabitRepositoryImpl(database);
  final scoringRepository = ScoringRepositoryImpl(database);

  // Use Cases — сессии
  final initializeSessionUseCase = InitializeSessionUseCase(database);
  final startControlSessionUseCase = StartControlSessionUseCase(database);
  final getSessionsByDayUseCase = GetSessionsByDayUseCase(sessionRepository);

  // Use Cases — скоринг
  final calculateScoreUseCase = CalculateScoreUseCase(scoringRepository);
  final verifyCalibrationExpiryUseCase = VerifyCalibrationExpiryUseCase(
    sessionRepository: sessionRepository,
    scoringRepository: scoringRepository,
  );
  final getDopamineBalanceUseCase = GetCurrentDopamineBalanceUseCase(
    sessionRepository: sessionRepository,
    scoringRepository: scoringRepository,
  );

  final weeklyReportUseCase = CheckAndGenerateWeeklyReportUseCase(
    sessionRepository: sessionRepository,
  );

  // Use Cases — привычки
  final addActionUseCase = AddActionUseCase(database);

  // Notifiers
  final sessionsNotifier = SessionsNotifier(
    sessionRepository: sessionRepository,
    initializeSessionUseCase: initializeSessionUseCase,
    startControlSessionUseCase: startControlSessionUseCase,
  );

  // HabitsNotifier теперь сам подписывается на sessionId через стрим сессии
  final habitsNotifier = HabitsNotifier(
    habitRepository: habitRepository,
    sessionRepository: sessionRepository,
    addActionUseCase: addActionUseCase,
  );

  final scoringNotifier = ScoringNotifier(

    sessionRepository: sessionRepository,
    scoringRepository: scoringRepository,

    verifyCalibrationExpiry: verifyCalibrationExpiryUseCase,
    getDopamineBalance: getDopamineBalanceUseCase,
  );

  // ControlScreenNotifier не нужен getDopamineBalance — сам считает из стримов
  final controlScreenNotifier = ControlScreenNotifier(
    sessionRepository: sessionRepository,
    habitRepository: habitRepository,
  );

  runApp(MyApp(
    database: database,
    sessionsNotifier: sessionsNotifier,
    habitsNotifier: habitsNotifier,
    scoringNotifier: scoringNotifier,
    controlScreenNotifier: controlScreenNotifier,
    weeklyReportUseCase: weeklyReportUseCase,
  ));
}

class MyApp extends StatelessWidget {
  final AppDatabase database;
  final SessionsNotifier sessionsNotifier;
  final HabitsNotifier habitsNotifier;
  final ScoringNotifier scoringNotifier;
  final ControlScreenNotifier controlScreenNotifier;
  final CheckAndGenerateWeeklyReportUseCase weeklyReportUseCase;

  const MyApp({
    super.key,
    required this.database,
    required this.sessionsNotifier,
    required this.habitsNotifier,
    required this.scoringNotifier,
    required this.controlScreenNotifier,
    required this.weeklyReportUseCase,
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
        weeklyReportUseCase: weeklyReportUseCase,
      ),
    );
  }
}