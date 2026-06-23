import 'package:flutter/material.dart';
import 'package:dopamine_budget/features/habits/presentation/widgets/habit_management_body.dart';
import 'package:dopamine_budget/features/habits/presentation/state/habits_notifier.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';

class SessionSettingsSheet extends StatelessWidget {
  final Session session;
  final HabitsNotifier habitsNotifier;
  final Future<void> Function() onArchive;

  const SessionSettingsSheet({
    super.key,
    required this.session,
    required this.habitsNotifier,
    required this.onArchive,
  });

  static Future<void> show({
    required BuildContext context,
    required Session session,
    required HabitsNotifier habitsNotifier,
    required Future<void> Function() onArchive,
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
      // Сначала вызываем onArchive — она сама управляет навигацией
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Темп усыхания',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Настройки усыхания — задача 2',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
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
}