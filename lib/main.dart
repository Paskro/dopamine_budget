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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Создаем ОДИН экземпляр SQL базы данных
  final database = AppDatabase();

  // 2. Настраиваем фичу Сессий
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

  // 4. Настраиваем фичу Скоринга через Репозиторий
  final sessionRepository = SessionRepositoryImpl(database);
  final scoringRepository = ScoringRepositoryImpl(database);
  final calculateScoreUseCase = CalculateScoreUseCase(scoringRepository);

  final scoringNotifier = ScoringNotifier(
    calculateScoreUseCase: calculateScoreUseCase,
    sessionRepository: sessionRepository,
  );

  // Старые UseCase сессий сохраняем для совместимости, если нужны UI
  final addSessionUseCase = AddSessionUseCase(sessionRepository);
  final getSessionsByDayUseCase = GetSessionsByDayUseCase(sessionRepository);
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

class HomePage extends StatefulWidget {
  final AppDatabase database;
  final ScoringNotifier scoringNotifier;
  final HabitsNotifier habitsNotifier;

  const HomePage({
    super.key,
    required this.database,
    required this.scoringNotifier,
    required this.habitsNotifier,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String dbStatus = 'Подключено к единой БД';
  int rowsInDbCount = 0;

  @override
    void initState() {
      super.initState();
      widget.scoringNotifier.addListener(_update);
      widget.habitsNotifier.addListener(_update);

      // ПРИНУДИТЕЛЬНО заставляем скоринг проснуться и прочитать базу данных
      widget.scoringNotifier.refreshTodayState();
      _refreshDbCount();
      widget.habitsNotifier.loadHabits();
    }

  @override
  void dispose() {
    widget.scoringNotifier.removeListener(_update);
    widget.habitsNotifier.removeListener(_update);
    super.dispose();
  }

  void _update() {
    setState(() {});
    _refreshDbCount();
  }

  Future<void> _refreshDbCount() async {
    try {
      final allRows = await widget.database.select(widget.database.actionsTable).get();
      setState(() {
        rowsInDbCount = allRows.length;
      });
    } catch (e) {
      print('Не удалось прочитать данные из единой БД: $e');
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
              const Text('Дофаминовый бюджет потрачен сегодня:', style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 5),
              // Выводим сколько потрачено из общего лимита
              Text(
                '${scoringState.pointsSpentToday} / ${scoringState.dailyLimit} XP',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: scoringState.isOverLimit ? Colors.red : Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              Text('Копилка геймификации: ${scoringState.gamificationPoints} XP', style: const TextStyle(fontSize: 14, color: Colors.purple, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text('Записей в SQL-базе: $rowsInDbCount', style: const TextStyle(fontSize: 12, color: Colors.blue)),
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
                                      // Вызываем метод с маленькой буквы, как он объявлен в Notifier
                                      widget.scoringNotifier.spendDopamine(habit.title, habit.scoreValue);
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