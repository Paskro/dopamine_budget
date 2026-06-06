import 'package:flutter/material.dart';
import '../state/habits_notifier.dart';
import '../../domain/entities/habit.dart';

class HabitManagementPage extends StatefulWidget {
  final HabitsNotifier habitsNotifier;
  final String sessionId;

  const HabitManagementPage({
    Key? key,
    required this.habitsNotifier,
    required this.sessionId,
  }) : super(key: key);

  @override
  State<HabitManagementPage> createState() => _HabitManagementPageState();
}

class _HabitManagementPageState extends State<HabitManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  int _scoreValue = 5;

  Habit? _editingHabit;

  @override
  void initState() {
    super.initState();
    widget.habitsNotifier.addListener(_onStateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.habitsNotifier.loadHabits(currentSessionId: widget.sessionId);
    });
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.habitsNotifier.removeListener(_onStateChanged);
    _titleController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _titleController.clear();
    setState(() {
      _scoreValue = 5;
      _editingHabit = null;
    });
  }

  void _startEditing(Habit habit) {
    _titleController.text = habit.title;          // было: habit.name
    setState(() {
      _scoreValue = habit.scoreValue.clamp(1, 10); // было: habit.score
      _editingHabit = habit;
    });
  }

  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();

    if (_editingHabit != null) {
      // Создаём обновлённый объект Habit и передаём его в updateHabit
      final updatedHabit = Habit(
        id: _editingHabit!.id,
        title: title,
        scoreValue: _scoreValue,
      );
      widget.habitsNotifier.updateHabit(updatedHabit);
    } else {
      widget.habitsNotifier.addHabit(title, _scoreValue);
    }

    _resetForm();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    // habits возвращает List<Habit> напрямую
    final habits = widget.habitsNotifier.habits;
    final isLoading = widget.habitsNotifier.isLoading;

    // Берём выбранные ID прямо из стейта (было: selectedHabits.map(...))
    final selectedIds = widget.habitsNotifier.selectedHabitIds.toSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление привычками'),
        centerTitle: true,
        actions: _editingHabit != null
            ? [
                IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: _resetForm,
                  tooltip: 'Отменить редактирование',
                )
              ]
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              key: const ValueKey('HabitFormKey'),
              child: Form(
                key: _formKey,
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _editingHabit != null
                              ? 'Редактирование привычки'
                              : 'Создать новую глобальную привычку',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Название привычки',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Введите название';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text('Стоимость: $_scoreValue баллов', style: const TextStyle(fontSize: 15)),
                            Expanded(
                              child: Slider(
                                value: _scoreValue.toDouble(),
                                min: 1,
                                max: 10,
                                divisions: 9,
                                label: _scoreValue.toString(),
                                onChanged: (val) {
                                  setState(() {
                                    _scoreValue = val.toInt();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: isLoading ? null : _onSavePressed,
                          icon: Icon(_editingHabit != null ? Icons.check : Icons.add),
                          label: Text(_editingHabit != null ? 'Сохранить изменения' : 'Добавить в справочник'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Выберите привычки для текущей сессии:',
                style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
              ),
            ),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : habits.isEmpty
                      ? const Center(
                          child: Text(
                            'Справочник привычек пуст.\nСоздайте первую привычку выше.',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          itemCount: habits.length,
                          itemBuilder: (context, index) {
                            final habit = habits[index];
                            // selectedIds содержит int, habit.id — String; парсим для сравнения
                            final habitIdInt = int.tryParse(habit.id) ?? -1;
                            final isSelected = selectedIds.contains(habitIdInt);

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: ListTile(
                                leading: Checkbox(
                                  value: isSelected,
                                  onChanged: isLoading
                                      ? null
                                      : (bool? checked) {
                                          // убрали лишний параметр isSelected — его нет в методе
                                          widget.habitsNotifier.toggleHabitSelection(
                                            widget.sessionId,
                                            int.parse(habit.id), // <- ИСПРАВЛЕНО: приведение String к int для Drift
                                          );
                                        },
                                ),
                                title: Text(habit.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Стоимость: ${habit.scoreValue} б.'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: isLoading ? null : () => _startEditing(habit),
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(8),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: isLoading ? null : () => _showDeleteConfirmation(habit),
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(8),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Habit habit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить привычку?'),
        content: Text(
          'Вы действительно хотите удалить "${habit.title}" из глобального справочника?\nОна также исчезнет из текущей сессии.',
        ), // было: habit.name
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              final habitId = int.tryParse(habit.id) ?? 0;
              if (habitId != 0) {
                widget.habitsNotifier.deleteHabit(habitId, sessionId: widget.sessionId);
              }
              if (_editingHabit?.id == habit.id) _resetForm();
              Navigator.pop(ctx);
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}