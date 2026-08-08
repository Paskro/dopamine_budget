import 'package:flutter/material.dart';
import '../state/habits_notifier.dart';
import '../../domain/entities/habit.dart';

class HabitManagementBody extends StatefulWidget {
  final HabitsNotifier habitsNotifier;
  final String sessionId;

  const HabitManagementBody({
    super.key,
    required this.habitsNotifier,
    required this.sessionId,
  });

  @override
  State<HabitManagementBody> createState() => _HabitManagementBodyState();
}

class _HabitManagementBodyState extends State<HabitManagementBody> {
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

  void _onStateChanged() { if (mounted) setState(() {}); }

  @override
  void dispose() {
    widget.habitsNotifier.removeListener(_onStateChanged);
    _titleController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _titleController.clear();
    setState(() { _scoreValue = 5; _editingHabit = null; });
  }

  void _startEditing(Habit habit) {
    _titleController.text = habit.title;
    setState(() { _scoreValue = habit.scoreValue.clamp(1, 10); _editingHabit = habit; });
  }

  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) return;
    final title = _titleController.text.trim();
    if (_editingHabit != null) {
      widget.habitsNotifier.updateHabit(
        Habit(id: _editingHabit!.id, title: title, scoreValue: _scoreValue),
      );
    } else {
      widget.habitsNotifier.addHabit(title, _scoreValue);
    }
    _resetForm();
    FocusScope.of(context).unfocus();
  }

  void _showDeleteConfirmation(Habit habit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Архивировать привычку?'),
        content: Text('"${habit.title}" будет скрыта. История сохранится.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          TextButton(
            onPressed: () {
              widget.habitsNotifier.archiveHabit(habit.id);
              if (_editingHabit?.id == habit.id) _resetForm();
              Navigator.pop(ctx);
            },
            child: const Text('Архивировать', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habits = widget.habitsNotifier.habits;
    final isLoading = widget.habitsNotifier.isLoading;
    final selectedIds = widget.habitsNotifier.selectedHabitIds.toSet();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Form(
            key: _formKey,
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _editingHabit != null ? 'Редактирование' : 'Новая привычка',
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
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Введите название' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text('Стоимость: $_scoreValue б.'),
                        Expanded(
                          child: Slider(
                            value: _scoreValue.toDouble(),
                            min: 1, max: 10, divisions: 9,
                            label: _scoreValue.toString(),
                            onChanged: (v) => setState(() => _scoreValue = v.toInt()),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : _onSavePressed,
                      icon: Icon(_editingHabit != null ? Icons.check : Icons.add),
                      label: Text(_editingHabit != null ? 'Сохранить' : 'Добавить'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Divider(height: 1),
        SizedBox(
          height: 280,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : habits.isEmpty
              ? const Center(child: Text('Справочник пуст. Создайте первую привычку.'))
              : ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              final habitIdInt = int.tryParse(habit.id) ?? -1;
              final isSelected = selectedIds.contains(habit.id);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: Checkbox(
                    value: isSelected,
                    onChanged: isLoading ? null : (_) =>
                        widget.habitsNotifier.toggleHabitSelection(widget.sessionId, habit.id),
                  ),
                  title: Text(habit.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${habit.scoreValue} б.'),
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
    );
  }
}