import 'package:flutter/material.dart';
import 'package:dopamine_budget/features/habits/presentation/widgets/habit_management_body.dart';
import 'package:dopamine_budget/features/habits/presentation/state/habits_notifier.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';
import 'package:dopamine_budget/features/scoring/presentation/state/scoring_notifier.dart';

class SessionSettingsSheet extends StatelessWidget {
  final Session session;
  final HabitsNotifier habitsNotifier;
  final ScoringNotifier scoringNotifier;

  const SessionSettingsSheet({
    super.key,
    required this.session,
    required this.habitsNotifier,
    required this.scoringNotifier,
  });

  static Future<void> show({
    required BuildContext context,
    required Session session,
    required HabitsNotifier habitsNotifier,
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
        scoringNotifier: scoringNotifier,
      ),
    );
  }

  Future<void> _confirmDisableShrinking(
      BuildContext context, ScoringNotifier scoringNotifier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Отключить усыхание?'),
        content: const Text(
          'Текущий лимит будет зафиксирован как новая база. '
              'Повторное включение начнёт отсчёт от этого значения.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Отключить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await scoringNotifier.toggleShrinking(false);
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
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Темп усыхания',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            _ShrinkingSettings(
                              scoringNotifier: scoringNotifier,
                              isEditAllowed: scoringNotifier.state.isShrinkEditAllowed,
                              onDisable: () => _confirmDisableShrinking(context, scoringNotifier),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
} // <--- СКОБКА ПЕРЕНЕСЕНА СЮДА. Класс SessionSettingsSheet успешно закрыт.

class _ShrinkingSettings extends StatefulWidget {
  final ScoringNotifier scoringNotifier;
  final bool isEditAllowed;
  final VoidCallback onDisable;

  const _ShrinkingSettings({
    required this.scoringNotifier,
    required this.isEditAllowed,
    required this.onDisable,
  });

  @override
  State<_ShrinkingSettings> createState() => _ShrinkingSettingsState();
}

class _ShrinkingSettingsState extends State<_ShrinkingSettings> {
  late double _pct;
  late String _interval;

  @override
  void initState() {
    super.initState();
    _pct = widget.scoringNotifier.state.decreasePercentage ?? 2.0;
    _interval = widget.scoringNotifier.state.decreaseInterval ?? 'week';
  }

  String get _previewText {
    final base = widget.scoringNotifier.state.dailyLimit;
    final next = base * (1 - _pct / 100);
    final periodLabel = _interval == 'week' ? '7 дней' : '1 месяц';
    return 'Сейчас: ${base.round()} баллов. '
        'Через $periodLabel станет: ${next.round()} баллов';
  }

  Future<void> _confirm() async {
    await widget.scoringNotifier.toggleShrinking(
      true,
      pct: _pct,
      interval: _interval,
    );
  }

  Future<void> _applyEdit() async {
    await widget.scoringNotifier.toggleShrinking(false);
    await widget.scoringNotifier.toggleShrinking(true, pct: _pct, interval: _interval);
  }

  @override
  Widget build(BuildContext context) {
    final isShrinkingActive = widget.scoringNotifier.state.isShrinkingEnabled;
    final canEdit = !isShrinkingActive || widget.isEditAllowed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Снижение:', style: TextStyle(fontSize: 13)),
            Text('${_pct.round()}%',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: _pct.clamp(2.0, 30.0),
          min: 2,
          max: 30,
          divisions: 28,
          label: '${_pct.round()}%',
          onChanged: canEdit ? (val) => setState(() => _pct = val) : null,
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
          onSelectionChanged: canEdit
              ? (val) => setState(() => _interval = val.first)
              : null,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _previewText,
            style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
          ),
        ),
        const SizedBox(height: 16),
        if (!isShrinkingActive)
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _confirm,
              child: const Text('Активировать'),
            ),
          ),
        if (isShrinkingActive && widget.isEditAllowed)
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _applyEdit,
              child: const Text('Применить'),
            ),
          ),

        if (isShrinkingActive && !widget.isEditAllowed)
          Text(
            'Изменение параметров доступно в первый день нового периода.',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: widget.onDisable,
            child: const Text('Отключить'),
          ),
        ),
      ],
    );
  }
}