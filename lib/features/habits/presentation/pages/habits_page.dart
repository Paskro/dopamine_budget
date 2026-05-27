import 'package:flutter/material.dart';
import '../../domain/entities/habit.dart';
import '../state/habits_notifier.dart';

class HabitsPage extends StatefulWidget {
  final HabitsNotifier notifier;

  const HabitsPage({super.key, required this.notifier});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  final _titleController = TextEditingController();
  double _scoreValue = 5;

  // Новая переменная: хранит привычку, которую мы сейчас редактируем.
  // Если там пусто (null) — приложение понимает, что мы просто создаем новую привычку.
  Habit? _editingHabit;

  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(_update);
    widget.notifier.loadHabits();
  }

  void _update() => setState(() {});

  @override
  void dispose() {
    widget.notifier.removeListener(_update);
    _titleController.dispose();
    super.dispose();
  }

  // Главная кнопка действия (Сохранить или Добавить)
  void _onSavePressed() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    if (_editingHabit != null) {
      // Если мы в режиме редактирования — обновляем старую запись в SQL
      final updated = _editingHabit!.copyWith(
        title: title,
        scoreValue: _scoreValue.toInt(),
      );
      widget.notifier.updateHabit(updated);
    } else {
      // Если режим обычный — создаем новую запись в SQL
      widget.notifier.addHabit(title, _scoreValue.toInt());
    }

    _resetForm();
  }

  // Включаем режим редактирования: переносим данные из списка в верхнюю форму
  void _startEditing(Habit habit) {
    setState(() {
      _editingHabit = habit;
      _titleController.text = habit.title;
      _scoreValue = habit.scoreValue.toDouble();
    });
  }

  // Очистка формы и выход из режима редактирования
  void _resetForm() {
    _titleController.clear();
    setState(() {
      _scoreValue = 5;
      _editingHabit = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.notifier.state;

    return Scaffold(
      appBar: AppBar(title: const Text('Управление привычками')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Форма добавления / редактирования
            Card(
              elevation: 4,
              color: _editingHabit != null ? Colors.orange.shade50 : null, // Подсветим форму при изменении
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    if (_editingHabit != null) ...[
                      const Row(
                        children: [
                          Icon(Icons.edit, color: Colors.orange, size: 16),
                          SizedBox(width: 6),
                          Text('Режим редактирования', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Название привычки (напр., Сигареты)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text('Баллы (Дофамин): ${_scoreValue.toInt()}'),
                        Expanded(
                          child: Slider(
                            value: _scoreValue,
                            min: 1,
                            max: 10,
                            divisions: 9,
                            label: _scoreValue.toInt().toString(),
                            onChanged: (val) {
                              setState(() {
                                _scoreValue = val;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _onSavePressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _editingHabit != null ? Colors.orange : null,
                            foregroundColor: _editingHabit != null ? Colors.white : null,
                          ),
                          child: Text(_editingHabit != null ? 'Сохранить изменения' : 'Добавить привычку'),
                        ),
                        if (_editingHabit != null) ...[
                          const SizedBox(width: 10),
                          TextButton(
                            onPressed: _resetForm,
                            child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
                          ),
                        ]
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ваши привычки в SQL:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Список привычек с кнопками управления
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.habits.isEmpty
                      ? const Center(child: Text('Список пуст. Добавьте первую!'))
                      : ListView.builder(
                          itemCount: state.habits.length,
                          itemBuilder: (context, index) {
                            final habit = state.habits[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.orange.shade100,
                                  child: Text(
                                    '-${habit.scoreValue}',
                                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(habit.title),
                                subtitle: Text('ID в базе: ${habit.id}'),
                                // КНОПКИ УДАЛЕНИЯ И РЕДАКТИРОВАНИЯ СПРАВА
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Кнопка Карандаш (Редактировать)
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _startEditing(habit),
                                    ),
                                    // Кнопка Корзина (Удалить)
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        // Вызываем удаление из SQL через наш менеджер состояния
                                        widget.notifier.deleteHabit(habit.id);
                                        // Если удалили ту, которую редактировали в этот момент — очистим форму
                                        if (_editingHabit?.id == habit.id) _resetForm();
                                      },
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
}