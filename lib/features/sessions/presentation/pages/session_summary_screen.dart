import 'package:flutter/material.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/delete_session_use_case.dart';

class SessionSummaryScreen extends StatelessWidget {
  final Session session;
  final DeleteSessionUseCase deleteSessionUseCase;
  final bool fromHistory;
  final VoidCallback? onComplete;

  const SessionSummaryScreen({
    super.key,
    required this.session,
    required this.deleteSessionUseCase,
    this.fromHistory = false,
    this.onComplete,
  });

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить сессию?'),
        content: const Text('Это сотрёт всю историю кликов внутри этой сессии. Действие необратимо.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await deleteSessionUseCase.execute(session.id);
      if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Итоги сессии')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!fromHistory) ...[
              const Icon(Icons.emoji_events_outlined, size: 64, color: Colors.amber),
              const SizedBox(height: 16),
              Text(
                'Сессия завершена',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Спасибо за работу над собой',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (onComplete != null) {
                    onComplete!();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('К новым приключениям'),
              ),
            ] else ...[
              if (session.avgScore != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Средний балл', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                        Text('${session.avgScore!.round()} XP', style: Theme.of(context).textTheme.headlineMedium),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Начало сессии', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                      Text(
                        '${session.createdAt.day.toString().padLeft(2, '0')}.${session.createdAt.month.toString().padLeft(2, '0')}.${session.createdAt.year}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              const Divider(),
              OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text('Удалить сессию', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}