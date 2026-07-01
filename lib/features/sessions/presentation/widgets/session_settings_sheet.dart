import 'package:flutter/material.dart';
import 'package:dopamine_budget/features/habits/presentation/widgets/habit_management_body.dart';
import 'package:dopamine_budget/features/habits/presentation/state/habits_notifier.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';
import 'package:dopamine_budget/features/scoring/presentation/state/scoring_notifier.dart';

class SessionSettingsSheet extends StatelessWidget {
  final Session session;
  final HabitsNotifier habitsNotifier;
  final Future<void> Function() onArchive;
  final ScoringNotifier scoringNotifier;

  const SessionSettingsSheet({
    super.key,
    required this.session,
    required this.habitsNotifier,
    required this.onArchive,
    required this.scoringNotifier,
  });

  static Future<void> show({
    required BuildContext context,
    required Session session,
    required HabitsNotifier habitsNotifier,
    required Future<void> Function() onArchive,
    required ScoringNotifier scoringNotifier,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SessionSettingsSheet(
        session: session,
        habitsNotifier: habitsNotifier,
        onArchive: onArchive,
        scoringNotifier: scoringNotifier,
      ),
    );
  }

  Future<void> _confirmArchive(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Завершить сессию?'),
        content: const Text(
          'Сессия будет закрыта. Для продолжения нужно будет начать новую сессию.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Завершить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await onArchive();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Настройки сессии',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (session.phase == 0)
              HabitManagementBody(
                habitsNotifier: habitsNotifier,
                sessionId: session.id,
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListenableBuilder(
                      listenable: scoringNotifier,
                      builder: (context, _) {
                        final isShrinking = scoringNotifier.state.isShrinkingEnabled;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Темп усыхания',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            SwitchListTile(
                              title: const Text('Усыхание активно',
                                  style: TextStyle(fontSize: 14)),
                              subtitle: const Text(
                                  'Лимит снижается согласно заданному темпу',
                                  style: TextStyle(fontSize: 12)),
                              value: isShrinking,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (val) => scoringNotifier.toggleShrinking(val),
                            ),
                            if (isShrinking) ...[
                              const SizedBox(height: 16),
                              _ShrinkingSettings(scoringNotifier: scoringNotifier),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Divider(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.stop_circle_outlined, color: Colors.red),
                  label: const Text(
                    'Завершить сессию',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                  onPressed: () => _confirmArchive(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} // <--- СКОБКА ПЕРЕНЕСЕНА СЮДА. Класс SessionSettingsSheet успешно закрыт.

class _ShrinkingSettings extends StatefulWidget {
  final ScoringNotifier scoringNotifier;
  const _ShrinkingSettings({required this.scoringNotifier});

  @override
  State<_ShrinkingSettings> createState() => _ShrinkingSettingsState();
}

class _ShrinkingSettingsState extends State<_ShrinkingSettings> {
  late double _pct;
  late String _interval;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _pct = widget.scoringNotifier.state.decreasePercentage ?? 2.0;
    _interval = widget.scoringNotifier.state.decreaseInterval ?? 'week';
  }

  void _onPctChanged(double val) {
    setState(() {
      _pct = val;
      _isDirty = _hasChanges();
    });
  }

  void _onIntervalChanged(String val) {
    setState(() {
      _interval = val;
      _isDirty = _hasChanges();
    });
  }

  bool _hasChanges() {
    final state = widget.scoringNotifier.state;
    return _pct != (state.decreasePercentage ?? 2.0) ||
        _interval != (state.decreaseInterval ?? 'week');
  }

  Future<void> _apply() async {
    await widget.scoringNotifier.updateDecreaseSettings(
      percentage: _pct,
      interval: _interval,
    );
    if (mounted) setState(() => _isDirty = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Снижение:', style: TextStyle(fontSize: 13)),
            Text('${_pct.round()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: _pct.clamp(2.0, 30.0),
          min: 2,
          max: 30,
          divisions: 28,
          label: '${_pct.round()}%',
          onChanged: _onPctChanged,
        ),
        if (_pct > 15)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              '⚠ Высокий риск срыва. Рекомендуемый темп — 5–10%.',
              style: TextStyle(fontSize: 11, color: Colors.orange),
            ),
          ),
        const Text('Период снижения:', style: TextStyle(fontSize: 13)),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'week', label: Text('Неделя (7 дн.)')),
            ButtonSegment(value: 'month', label: Text('Месяц')),
          ],
          selected: {_interval},
          onSelectionChanged: (val) => _onIntervalChanged(val.first),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _isDirty ? _apply : null,
            child: const Text('Применить'),
          ),
        ),
      ],
    );
  }
}