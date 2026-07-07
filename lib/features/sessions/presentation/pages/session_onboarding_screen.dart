import 'package:flutter/material.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/delete_session_use_case.dart';
import 'package:dopamine_budget/features/sessions/presentation/pages/profile_screen.dart';
import 'package:dopamine_budget/features/habits/presentation/state/habits_notifier.dart';
import 'package:dopamine_budget/features/habits/presentation/pages/habit_management_page.dart';

enum _OnboardingStep { intro, habitsSelection, limitInput }

class SessionOnboardingScreen extends StatefulWidget {
  final SessionRepository sessionRepository;
  final DeleteSessionUseCase deleteSessionUseCase;
  final Function(int days) onStartCalibration;
  final HabitsNotifier habitsNotifier;
  final Future<void> Function({
  required double limit,
  required Set<int> habitIds,
  }) onStartControlWithHabits;

  const SessionOnboardingScreen({
    super.key,
    required this.onStartCalibration,
    required this.onStartControlWithHabits,
    required this.sessionRepository,
    required this.deleteSessionUseCase,
    required this.habitsNotifier,
  });

  @override
  State<SessionOnboardingScreen> createState() =>
      _SessionOnboardingScreenState();
}

class _SessionOnboardingScreenState extends State<SessionOnboardingScreen> {
  final _calibDaysController = TextEditingController(text: '7');
  final _limitController = TextEditingController(text: '100');

  _OnboardingStep _step = _OnboardingStep.intro;
  Set<int> _wizardSelectedHabitIds = {};
  bool _isStarting = false;

  @override
  void dispose() {
    _calibDaysController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  void _showCalibrationDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Период калибровки'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Сколько дней вы хотите собирать статистику срывов?'),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () =>
                        setDialogState(() => _calibDaysController.text = '3'),
                    child: const Text('3 дня'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () =>
                        setDialogState(() => _calibDaysController.text = '7'),
                    child: const Text('7 дней (Реком.)'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _calibDaysController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Свой вариант (дней)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                final days = int.tryParse(_calibDaysController.text) ?? 7;
                Navigator.pop(context);
                widget.onStartCalibration(days);
              },
              child: const Text('Запустить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(
                  sessionRepository: widget.sessionRepository,
                  deleteSessionUseCase: widget.deleteSessionUseCase,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.psychology, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'Добро пожаловать в\nDopamine Budget',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Выберите стратегию работы со своими триггерами и привычками:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue.shade50,
                  foregroundColor: Colors.blue.shade900,
                ),
                icon: const Icon(Icons.bar_chart),
                label: const Text(
                  'Запустить калибровку (Рекомендуется)',
                  style: TextStyle(fontSize: 15),
                ),
                onPressed: _showCalibrationDialog,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.tune),
                label: const Text(
                  'Я сам установлю лимит (Контроль)',
                  style: TextStyle(fontSize: 15),
                ),
                onPressed: () => setState(() {
                  _wizardSelectedHabitIds = {};
                  _step = _OnboardingStep.habitsSelection;
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHabitsSelection() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сначала выберем привычки для контроля'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _step = _OnboardingStep.intro),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _step = _OnboardingStep.intro),
                    child: const Text('Назад'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _wizardSelectedHabitIds.isEmpty
                        ? null
                        : () => setState(() => _step = _OnboardingStep.limitInput),
                    child: const Text('Продолжить'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: HabitManagementPage(
        habitsNotifier: widget.habitsNotifier,
        sessionId: '',
        embedded: true,
        localSelectedIds: _wizardSelectedHabitIds,
        onLocalSelectionChanged: (ids) =>
            setState(() => _wizardSelectedHabitIds = ids),
      ),
    );
  }

  Widget _buildLimitInput() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Дневной лимит'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _step = _OnboardingStep.habitsSelection),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _step = _OnboardingStep.intro),
                    child: const Text('Вернуться к выбору фазы'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isStarting
                        ? null
                        : () async {
                      final limit = double.tryParse(_limitController.text) ?? 100.0;
                      setState(() => _isStarting = true);
                      try {
                        await widget.onStartControlWithHabits(
                          limit: limit,
                          habitIds: _wizardSelectedHabitIds,
                        );
                      } finally {
                        if (mounted) setState(() => _isStarting = false);
                      }
                    },
                    child: _isStarting
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text('Начать'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Укажите ваш лимит на эту сессию. Если вы не знаете — начните с фазы калибровки.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _limitController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Дневной бюджет (XP)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case _OnboardingStep.habitsSelection:
        return _buildHabitsSelection();
      case _OnboardingStep.limitInput:
        return _buildLimitInput();
      case _OnboardingStep.intro:
        return _buildIntro();
    }
  }
}