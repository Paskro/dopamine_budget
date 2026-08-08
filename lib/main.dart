import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import 'package:dopamine_budget/features/sessions/data/repositories/session_repository_impl.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/initialize_session_usecase.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/start_control_session_usecase.dart';
import 'package:dopamine_budget/features/sessions/presentation/state/sessions_notifier.dart';
import 'package:dopamine_budget/features/sessions/presentation/state/control_screen_notifier.dart';
import 'package:dopamine_budget/features/scoring/data/repositories/scoring_repository_impl.dart';
import 'package:dopamine_budget/features/scoring/presentation/state/scoring_notifier.dart';
import 'package:dopamine_budget/features/scoring/domain/usecases/get_current_dopamine_balance_usecase.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/verify_calibration_expiry_usecase.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/check_and_generate_weekly_report_usecase.dart';
import 'package:dopamine_budget/features/scoring/domain/usecases/get_weekly_habits_report_usecase.dart';
import 'package:dopamine_budget/features/actions/domain/usecases/add_action_usecase.dart';
import 'package:dopamine_budget/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:dopamine_budget/features/habits/presentation/state/habits_notifier.dart';
import 'package:dopamine_budget/presentation/root_gate.dart';
import 'package:dopamine_budget/core/utils/time_provider.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/archive_session_use_case.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/delete_session_use_case.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/features/scoring/domain/usecases/get_daily_limit_usecase.dart';
import 'package:dopamine_budget/features/scoring/domain/usecases/toggle_shrinking_mode_usecase.dart';
import 'package:dopamine_budget/core/notifications/notification_permission_helper.dart';
import 'package:dopamine_budget/core/notifications/notification_scheduler.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:dopamine_budget/features/sessions/domain/usecases/check_and_generate_shrinking_report_usecase.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/start_control_session_with_habits_usecase.dart';
import 'package:dopamine_budget/features/streak/data/repositories/streak_repository_impl.dart';
import 'package:dopamine_budget/features/streak/domain/usecases/sync_streak_usecase.dart';
import 'package:dopamine_budget/features/streak/presentation/state/streak_notifier.dart';
import 'package:dopamine_budget/core/theme/app_theme.dart';
import 'package:dopamine_budget/core/utils/haptic_service.dart';
import 'package:dopamine_budget/core/crypto/data/repositories/crypto_repository_impl.dart';
import 'package:dopamine_budget/core/crypto/data/services/crypto_session_service_impl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dopamine_budget/core/crypto/presentation/state/pin_notifier.dart';
import 'package:dopamine_budget/presentation/app_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dopamine_budget/features/auth/presentation/pages/deep_link_handler.dart';
import 'package:dopamine_budget/features/auth/auth_module.dart';
import 'package:dopamine_budget/core/sync/sync_service.dart';
import 'package:dopamine_budget/core/sync/active_session_service.dart';
import 'package:uuid/uuid.dart';
import 'package:dopamine_budget/core/crypto/domain/repositories/crypto_repository.dart';
import 'package:dopamine_budget/presentation/onboarding_gate.dart';
import 'package:dopamine_budget/features/auth/presentation/pages/auth_flow_coordinator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru', null);
  await TimeProvider.restore(); //ЗАКОММЕНТИТЬ В РЕЛИЗЕ
  tz_data.initializeTimeZones();
  final tzName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(tzName));
  await NotificationScheduler.init();
  await NotificationPermissionHelper.requestPermission();
  await NotificationPermissionHelper.requestExactAlarmPermission();
  await HapticService.init();
  await Supabase.initialize(
    url: 'https://iumeyfwzbgaxkfqsevzd.supabase.co',
    publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml1bWV5Znd6YmdheGtmcXNldnpkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODUxNDk5NDcsImV4cCI6MjEwMDcyNTk0N30.0eLBu35tCAr13rZLNnv4ACMMWLIh4tD6lxm0cDsLSfA',
  );
  await DeepLinkHandler.init();

  final secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  final database = AppDatabase.instance;
  final supabase = Supabase.instance.client;
  final cryptoSessionService = CryptoSessionServiceImpl();
  final cryptoRepository = CryptoRepositoryImpl(secureStorage);
  final syncService = SyncService(supabase, database, cryptoRepository, cryptoSessionService);
  const keyDeviceId = 'device_id';
  String? storedDeviceId = await secureStorage.read(key: keyDeviceId);
  if (storedDeviceId == null) {
    storedDeviceId = const Uuid().v4();
    await secureStorage.write(key: keyDeviceId, value: storedDeviceId);
  }
  final deviceId = storedDeviceId;
  final activeSessionService = ActiveSessionService(supabase, deviceId: deviceId);

  HabitsNotifier? habitsNotifierRef;

  final authModule = AuthModule.create(
    secureStorage,
    onPullAll: syncService.pullAll,
    onAfterPull: () => habitsNotifierRef?.reloadHabits() ?? Future.value(),
  );

  final pinNotifier = PinNotifier(
    cryptoRepository: cryptoRepository,
    cryptoSessionService: cryptoSessionService,
    onUnlocked: () async => habitsNotifierRef?.reloadHabits().catchError((_) {}),
  );

  // Репозитории
  final sessionRepository = SessionRepositoryImpl(database, sync: syncService);
  final habitRepository = HabitRepositoryImpl(database, cryptoRepository, cryptoSessionService);
  final scoringRepository = ScoringRepositoryImpl(database);

  // Use Cases — сессии
  final initializeSessionUseCase = InitializeSessionUseCase(database);
  final startControlSessionUseCase = StartControlSessionUseCase(
    database,
    sync: syncService,
  );
  final startControlSessionWithHabitsUseCase = StartControlSessionWithHabitsUseCase(database);

  final archiveSessionUseCase = ArchiveSessionUseCase(sessionRepository);
  final deleteSessionUseCase = DeleteSessionUseCase(sessionRepository);

  final getDailyLimitUseCase = GetDailyLimitUseCase(sessionRepository);
  final toggleShrinkingModeUseCase = ToggleShrinkingModeUseCase(
    sessionRepository: sessionRepository,
    getDailyLimitUseCase: getDailyLimitUseCase,
  );
  final verifyCalibrationExpiryUseCase = VerifyCalibrationExpiryUseCase(
    sessionRepository: sessionRepository,
    scoringRepository: scoringRepository,
  );
  final getDopamineBalanceUseCase = GetCurrentDopamineBalanceUseCase(
    sessionRepository: sessionRepository,
    scoringRepository: scoringRepository,
    getDailyLimitUseCase: getDailyLimitUseCase,
  );

  final weeklyReportUseCase = CheckAndGenerateWeeklyReportUseCase(
    sessionRepository: sessionRepository,
  );

  final shrinkingReportUseCase = CheckAndGenerateShrinkingReportUseCase(
    sessionRepository: sessionRepository,
    getDailyLimitUseCase: getDailyLimitUseCase,
  );

  final getWeeklyHabitsReportUseCase = GetWeeklyHabitsReportUseCase(scoringRepository);

  // Use Cases — привычки
  final addActionUseCase = AddActionUseCase(database, sync: syncService);

  // Streak
  final streakRepository = StreakRepositoryImpl(database, sync: syncService);
  final syncStreakUseCase = SyncStreakUseCase(streakRepository);
  final streakNotifier = StreakNotifier(
    syncStreakUseCase: syncStreakUseCase,
    repository: streakRepository,
  );

  // Notifiers

  // HabitsNotifier теперь сам подписывается на sessionId через стрим сессии
  final habitsNotifier = HabitsNotifier(
    habitRepository: habitRepository,
    sessionRepository: sessionRepository,
    addActionUseCase: addActionUseCase,
    sync: syncService,
  );

  habitsNotifierRef = habitsNotifier;

  final sessionsNotifier = SessionsNotifier(
    sessionRepository: sessionRepository,
    initializeSessionUseCase: initializeSessionUseCase,
    startControlSessionUseCase: startControlSessionUseCase,
    startControlSessionWithHabitsUseCase: startControlSessionWithHabitsUseCase,
  );

  final scoringNotifier = ScoringNotifier(
    sessionRepository: sessionRepository,
    scoringRepository: scoringRepository,
    verifyCalibrationExpiry: verifyCalibrationExpiryUseCase,
    getDopamineBalance: getDopamineBalanceUseCase,
    toggleShrinkingMode: toggleShrinkingModeUseCase,
    getDailyLimitUseCase: getDailyLimitUseCase,
  );

  // ControlScreenNotifier не нужен getDopamineBalance — сам считает из стримов
  final controlScreenNotifier = ControlScreenNotifier(
    sessionRepository: sessionRepository,
    habitRepository: habitRepository,
    getDailyLimitUseCase: getDailyLimitUseCase,
  );

  runApp(MyApp(
        database: database,
    pinNotifier: pinNotifier,
    cryptoRepository: cryptoRepository,
    sessionsNotifier: sessionsNotifier,
    habitsNotifier: habitsNotifier,
    scoringNotifier: scoringNotifier,
    controlScreenNotifier: controlScreenNotifier,
    weeklyReportUseCase: weeklyReportUseCase,
    getWeeklyHabitsReportUseCase: getWeeklyHabitsReportUseCase,
    archiveSessionUseCase: archiveSessionUseCase,
    deleteSessionUseCase: deleteSessionUseCase,
    sessionRepository: sessionRepository,
    shrinkingReportUseCase: shrinkingReportUseCase,
    streakNotifier: streakNotifier,
    authModule: authModule,
    activeSessionService: activeSessionService,
  ));
}

class MyApp extends StatelessWidget {
  final AppDatabase database;
  final SessionsNotifier sessionsNotifier;
  final HabitsNotifier habitsNotifier;
  final ScoringNotifier scoringNotifier;
  final ControlScreenNotifier controlScreenNotifier;
  final CheckAndGenerateWeeklyReportUseCase weeklyReportUseCase;
  final GetWeeklyHabitsReportUseCase getWeeklyHabitsReportUseCase;
  final ArchiveSessionUseCase archiveSessionUseCase;
  final DeleteSessionUseCase deleteSessionUseCase;
  final SessionRepository sessionRepository;
  final CheckAndGenerateShrinkingReportUseCase shrinkingReportUseCase;
  final StreakNotifier streakNotifier;
  final PinNotifier pinNotifier;
  final CryptoRepository cryptoRepository;
  final AuthModule authModule;
  final ActiveSessionService activeSessionService;

  const MyApp({
    super.key,
    required this.database,
    required this.sessionsNotifier,
    required this.habitsNotifier,
    required this.scoringNotifier,
    required this.controlScreenNotifier,
    required this.weeklyReportUseCase,
    required this.getWeeklyHabitsReportUseCase,
    required this.archiveSessionUseCase,
    required this.deleteSessionUseCase,
    required this.sessionRepository,
    required this.shrinkingReportUseCase,
    required this.streakNotifier,
    required this.pinNotifier,
    required this.cryptoRepository,
    required this.authModule,
    required this.activeSessionService
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dopamine Budget',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: OnboardingGate(
        authModule: authModule,
        onNewUser: (onDone) => AuthFlowCoordinator(
          authNotifier: authModule.authNotifier,
          pinNotifier: pinNotifier,
          uploadMasterKey: authModule.uploadMasterKeyUseCase,
          onComplete: onDone,
        ),
        child: AppGate(
            pinNotifier: pinNotifier,
            cryptoRepository: cryptoRepository,
            authModule: authModule,
            activeSessionService: activeSessionService,
            child: RootGate(
        database: database,
        sessionsNotifier: sessionsNotifier,
        habitsNotifier: habitsNotifier,
        scoringNotifier: scoringNotifier,
        controlScreenNotifier: controlScreenNotifier,
        weeklyReportUseCase: weeklyReportUseCase,
        getWeeklyHabitsReportUseCase: getWeeklyHabitsReportUseCase,
        archiveSessionUseCase: archiveSessionUseCase,
        deleteSessionUseCase: deleteSessionUseCase,
        sessionRepository: sessionRepository,
        shrinkingReportUseCase: shrinkingReportUseCase,
        streakNotifier: streakNotifier,
            ),
      ),
     ),
    );
  }
}