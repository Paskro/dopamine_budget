import 'package:flutter/material.dart';
import 'package:dopamine_budget/data/db/app_database.dart';

// Импорты фичи Сессий
import 'package:dopamine_budget/features/sessions/data/repositories/session_repository_impl.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/add_session_usecase.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/get_sessions_by_day_usecase.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/initialize_session_usecase.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/start_control_session_usecase.dart'; // НАШ НОВЫЙ КИРПИЧИК
import 'package:dopamine_budget/features/sessions/presentation/state/sessions_notifier.dart';

// Импорты фичи Скоринга
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

void main() async {
  // Гарантируем стабильную инициализацию плагинов Flutter перед стартом БД
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Создаем ОДИН экземпляр SQL базы данных для всего приложения
  final database = AppDatabase();

  // 2. Настраиваем фичу Сессий и наш новый SessionsNotifier
  final initializeSessionUseCase = InitializeSessionUseCase(database);
  final startControlSessionUseCase = StartControlSessionUseCase(database);

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

  // 4. Настраиваем логику действий и подсчета баллов
  final addActionUseCase = AddActionUseCase(database);
  final calculateScoreUseCase = CalculateScoreUseCase(database);

  final scoringNotifier = ScoringNotifier(
    addActionUseCase: addActionUseCase,
    calculateScoreUseCase: calculateScoreUseCase,
  );

  // Старые UseCase сессий (сохраняем, чтобы не ругался остальной код, если они где-то используются)
  final sessionRepository = SessionRepositoryImpl(database);
  final addSessionUseCase = AddSessionUseCase(sessionRepository);
  final getSessionsByDayUseCase = GetSessionsByDayUseCase(sessionRepository);

  // 5. Запускаем приложение и передаем готовые нотифайеры внутрь
  runApp(MyApp(
    sessionsNotifier: sessionsNotifier,
    habitsNotifier: habitsNotifier,
    scoringNotifier: scoringNotifier,
  ));
}

class MyApp extends StatelessWidget {
  final SessionsNotifier sessionsNotifier;
  final HabitsNotifier habitsNotifier;
  final ScoringNotifier scoringNotifier;

  const MyApp({
    super.key,
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
      // На входе теперь стоит RootGate, который решит: показать Onboarding или HomePage
      home: RootGate(
        sessionsNotifier: sessionsNotifier,
        habitsNotifier: habitsNotifier,
        scoringNotifier: scoringNotifier,
      ),
    );
  }
}

// Твой экран HomePage остался без изменений, но теперь он вызывается внутри RootGate
class HomePage extends StatefulWidget {
  final ScoringNotifier scoringNotifier;
  final HabitsNotifier habitsNotifier;

  const HomePage({
    super.key,
    required this.scoringNotifier,
    required this.habitsNotifier,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AppDatabase? db;
  String dbStatus = 'Инициализация...';
  int rowsInDbCount = 0;

  @override
  void initState() {
    super.initState();
    widget.scoringNotifier.addListener(_update);
    widget.habitsNotifier.addListener(_update);
    _initDatabaseSafe();
    widget.habitsNotifier.loadHabits();
  }

  @override
  void dispose() {
    widget.scoringNotifier.removeListener(_update);
    widget.habitsNotifier.removeListener(_update);
    db?.close();
    super.dispose();
  }

  void _update() {
    setState(() {});
    _refreshDbCount();
  }

  Future<void> _initDatabaseSafe() async {
    try {
      final database = AppDatabase();
      db = database;
      await _refreshDbCount();
      setState(() {
        dbStatus = 'База подключена успешно!';
      });
    } catch (e) {
      setState(() {
        dbStatus = 'Ошибка БД: $e';
      });
    }
  }

  Future<void> _refreshDbCount() async {
    if (db == null) return;
    try {
      final allRows = await db!.select(db!.actionsTable).get();
      setState(() {
        rowsInDbCount = allRows.length;
      });
    } catch (e) {
      print('Не удалось прочитать данные: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scoringState = widget.scoringNotifier.state;
    final habitsState = widget.habitsNotifier.state;

    return Scaffold(
      appBar: AppBar(title: const Text('Dopamine Budget')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Дофаминовый бюджет на сегодня:', style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 5),
              scoringState.isLoading
                ? const SizedBox(
                    height: 48,
                    width: 48,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                : Text(
                    '${scoringState.score} XP',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: scoringState.score > 50 ? Colors.green : Colors.orange
                    )
                  ),
              const SizedBox(height: 10),
              Text('Записей в SQL-базе: $rowsInDbCount', style: const TextStyle(fontSize: 14, color: Colors.blue)),
              const SizedBox(height: 30),
              const Text(
                'Нажмите на привычку при срыве:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: habitsState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : habitsState.habits.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('У вас пока нет созданных привычек.'),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => HabitsPage(notifier: widget.habitsNotifier)),
                                  ),
                                  child: const Text('Создать первую привычку'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: habitsState.habits.length,
                            itemBuilder: (context, index) {
                              final habit = habitsState.habits[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  title: Text(habit.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('Штраф: -${habit.scoreValue} XP'),
                                  trailing: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade400,
                                      foregroundColor: Colors.white
                                    ),
                                    onPressed: () {
                                      widget.scoringNotifier.SpendDopamine(habit);
                                    },
                                    child: const Text('Клац'),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
              const Divider(height: 40, thickness: 2),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HabitsPage(notifier: widget.habitsNotifier),
                    ),
                  );
                },
                icon: const Icon(Icons.settings),
                label: const Text('Управление привычками'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}