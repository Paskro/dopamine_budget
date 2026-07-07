import 'package:flutter/material.dart';
import '../state/habits_notifier.dart';
import '../../domain/entities/habit.dart';

class HabitManagementPage extends StatefulWidget {
  final HabitsNotifier habitsNotifier;
  final String sessionId;
  final bool readOnly;
  final Set<int>? localSelectedIds;
  final ValueChanged<Set<int>>? onLocalSelectionChanged;
  final bool embedded;

  const HabitManagementPage({
    Key? key,
    required this.habitsNotifier,
    required this.sessionId,
    this.readOnly = false,
    this.embedded = false,
    this.localSelectedIds,
    this.onLocalSelectionChanged,
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
      widget.habitsNotifier.addHabit(
        title,
        _scoreValue,
        localSelectedIds: widget.localSelectedIds,
        onLocalSelectionChanged: widget.onLocalSelectionChanged,
      );
    }

    _resetForm();
    FocusScope.of(context).unfocus();
  }

  Widget _buildBody() {
    final rawHabits = widget.habitsNotifier.habits;
    final isLoading = widget.habitsNotifier.isLoading;
    final isLocalMode = widget.localSelectedIds != null;
    final selectedIds = isLocalMode
        ? widget.localSelectedIds!
        : widget.habitsNotifier.selectedHabitIds.toSet();

    final habits = [...rawHabits]..sort((a, b) {
      final aSelected = selectedIds.contains(int.tryParse(a.id) ?? -1);
      final bSelected = selectedIds.contains(int.tryParse(b.id) ?? -1);
      if (aSelected != bSelected) return aSelected ? -1 : 1;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });

    return Column(
        children: [
          if (!widget.readOnly)
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
                                onChanged: (val) => setState(() => _scoreValue = val.toInt()),
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
                        if (isLocalMode) {
                          final updated = Set<int>.from(widget.localSelectedIds!);
                          updated.contains(habitIdInt)
                              ? updated.remove(habitIdInt)
                              : updated.add(habitIdInt);
                          widget.onLocalSelectionChanged!(updated);
                        } else {
                          widget.habitsNotifier.toggleHabitSelection(
                            widget.sessionId,
                            int.parse(habit.id),
                          );
                        }
                      },
                    ),
                    title: Text(habit.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Стоимость: ${habit.scoreValue} б.'),
                    trailing: widget.readOnly
                        ? null
                        : Row(
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

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) return _buildBody();
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
      body: _buildBody(),
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