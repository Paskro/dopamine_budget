import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../state/habits_notifier.dart';
import '../../domain/entities/habit.dart';

class HabitManagementPage extends StatefulWidget {
  final HabitsNotifier habitsNotifier;
  final String sessionId;
  final bool readOnly;
  final Set<String>? localSelectedIds;
  final ValueChanged<Set<String>>? onLocalSelectionChanged;
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
  String _selectedEmoji = '❓';
  bool _showEmojiPicker = false;

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
      _selectedEmoji = '❓';
      _showEmojiPicker = false;
    });
  }

  void _startEditing(Habit habit) {
    _titleController.text = habit.title;
    setState(() {
      _scoreValue = habit.scoreValue.clamp(1, 10);
      _selectedEmoji = habit.emoji;
      _editingHabit = habit;
      _showEmojiPicker = false;
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
        emoji: _selectedEmoji,
        scoreValue: _scoreValue,
      );
      widget.habitsNotifier.updateHabit(updatedHabit);
    } else {
      widget.habitsNotifier.addHabit(
        title,
        _scoreValue,
        _selectedEmoji,
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
      final aSelected = selectedIds.contains(a.id);
      final bSelected = selectedIds.contains(b.id);
      if (aSelected != bSelected) return aSelected ? -1 : 1;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });

    return CustomScrollView(
      slivers: [
        if (!widget.readOnly)
          SliverToBoxAdapter(
            child: Padding(
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
                            if (value == null || value.trim().isEmpty) return 'Введите название';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => setState(() => _showEmojiPicker = !_showEmojiPicker),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Text(_selectedEmoji, style: const TextStyle(fontSize: 24)),
                                const SizedBox(width: 8),
                                const Text('Выберите эмодзи', style: TextStyle(fontSize: 14)),
                                const Spacer(),
                                Icon(_showEmojiPicker ? Icons.expand_less : Icons.expand_more),
                              ],
                            ),
                          ),
                        ),
                        if (_showEmojiPicker)
                          SizedBox(
                            height: 250,
                            child: EmojiPicker(
                              onEmojiSelected: (category, emoji) {
                                setState(() {
                                  _selectedEmoji = emoji.emoji;
                                  _showEmojiPicker = false;
                                });
                              },
                              config: const Config(
                                height: 250,
                                emojiViewConfig: EmojiViewConfig(columns: 8),
                              ),
                            ),
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
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Выберите привычки для текущей сессии:',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
            ),
          ),
        ),
        if (isLoading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (habits.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Text(
                'Справочник привычек пуст.\nСоздайте первую привычку выше.',
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final habit = habits[index];
                final isSelected = selectedIds.contains(habit.id);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(habit.emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 4),
                        Checkbox(
                          value: isSelected,
                          onChanged: isLoading ? null : (bool? checked) {
                            if (isLocalMode) {
                              final updated = Set<String>.from(widget.localSelectedIds!);
                              updated.contains(habit.id) ? updated.remove(habit.id) : updated.add(habit.id);
                              widget.onLocalSelectionChanged!(updated);
                            } else {
                              widget.habitsNotifier.toggleHabitSelection(widget.sessionId, habit.id);
                            }
                          },
                        ),
                      ],
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
              childCount: habits.length,
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
        title: const Text('Архивировать привычку?'),
        content: Text(
          '"${habit.title}" будет скрыта из справочника.\nИстория кликов сохранится.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
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
}