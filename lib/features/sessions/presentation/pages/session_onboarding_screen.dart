import 'package:flutter/material.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/delete_session_use_case.dart';
import 'package:dopamine_budget/features/sessions/presentation/pages/profile_screen.dart';

class SessionOnboardingScreen extends StatefulWidget {
  final SessionRepository sessionRepository;
  final DeleteSessionUseCase deleteSessionUseCase;
  final Function(int days) onStartCalibration;
  final Function({
  required double limit,
  required bool shouldDecrease,
  double? percentage,
  String? interval,
  bool enableShrinking,
  }) onStartControl;

  const SessionOnboardingScreen({
    super.key,
    required this.onStartCalibration,
    required this.onStartControl,
    required this.sessionRepository,
    required this.deleteSessionUseCase,
  });

  @override
  State<SessionOnboardingScreen> createState() => _SessionOnboardingScreenState();
}

class _SessionOnboardingScreenState extends State<SessionOnboardingScreen> {
  // Для диалога калибровки
  final TextEditingController _calibDaysController = TextEditingController(text: '7');

  // Для диалога контроля
  final TextEditingController _limitController = TextEditingController(text: '100');
  final TextEditingController _percentController = TextEditingController(text: '5');
  bool _isShrinkingEnabled = false;
  bool _shouldDecrease = false;
  String _decreaseInterval = 'week';

  @override
  void dispose() {
    _calibDaysController.dispose();
    _limitController.dispose();
    _percentController.dispose();
    super.dispose();
  }

  // --- Диалог настройки Калибровки ---
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
                    onPressed: () => setDialogState(() => _calibDaysController.text = '3'),
                    child: const Text('3 дня'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => setDialogState(() => _calibDaysController.text = '7'),
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

  // --- Диалог настройки Контроля ---
  void _showControlDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Настройка Контроля'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Вы не проходили калибровку. Укажите стартовый дневной бюджет:',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _limitController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Дневной бюджет (XP)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Чекбокс деградации дофамина
                CheckboxListTile(
                  title: const Text('Снижать лимит со временем', style: TextStyle(fontSize: 14)),
                  value: _shouldDecrease,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) {
                    setDialogState(() => _shouldDecrease = val ?? false);
                  },
                ),
                if (_shouldDecrease) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _percentController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'На сколько процентов (%)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _decreaseInterval,
                    decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Интервал'),
                    items: const [
                      DropdownMenuItem(value: 'week', child: Text('Каждую неделю')),
                      DropdownMenuItem(value: 'month', child: Text('Каждый месяц')),
                    ],
                    onChanged: (val) {
                      setDialogState(() => _decreaseInterval = val ?? 'week');
                    },
                  ),
                ],
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Усыхание бюджета', style: TextStyle(fontSize: 14)),
                  subtitle: const Text('Лимит автоматически снижается со временем',
                      style: TextStyle(fontSize: 12)),
                  value: _isShrinkingEnabled,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) {
                    setDialogState(() => _isShrinkingEnabled = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                final limit = double.tryParse(_limitController.text) ?? 100.0;
                final percent = double.tryParse(_percentController.text) ?? 5.0;
                Navigator.pop(context);
                widget.onStartControl(
                  limit: limit,
                  shouldDecrease: _shouldDecrease,
                  percentage: _shouldDecrease ? percent : null,
                  interval: _shouldDecrease ? _decreaseInterval : null,
                  enableShrinking: _isShrinkingEnabled,
                );
              },
              child: const Text('Погнали!'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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

              // Кнопка 1: Калибровка
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue.shade50,
                  foregroundColor: Colors.blue.shade900,
                ),
                icon: const Icon(Icons.bar_chart),
                label: const Text('Запустить калибровку (Рекомендуется)', style: TextStyle(fontSize: 15)),
                onPressed: _showCalibrationDialog,
              ),
              const SizedBox(height: 16),

              // Кнопка 2: Ручной контроль
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.tune),
                label: const Text('Я сам установлю лимит (Контроль)', style: TextStyle(fontSize: 15)),
                onPressed: _showControlDialog,
              ),
            ],
          ),
        ),
      ),
    );
  }
}