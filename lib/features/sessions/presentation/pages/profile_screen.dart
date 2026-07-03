// lib/features/sessions/presentation/pages/profile_screen.dart
// ЗАМЕНИТЬ ВЕСЬ ФАЙЛ
import 'package:flutter/material.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/delete_session_use_case.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/archive_session_use_case.dart';
import 'package:dopamine_budget/features/habits/presentation/state/habits_notifier.dart';
import 'package:dopamine_budget/features/habits/presentation/pages/habit_management_page.dart';
import 'package:dopamine_budget/features/sessions/presentation/pages/session_summary_screen.dart';
import 'past_sessions_screen.dart';

class ProfileScreen extends StatelessWidget {
  final SessionRepository sessionRepository;
  final DeleteSessionUseCase deleteSessionUseCase;
  final Session? activeSession;
  final HabitsNotifier? habitsNotifier;
  final ArchiveSessionUseCase? archiveSessionUseCase;

  const ProfileScreen({
    super.key,
    required this.sessionRepository,
    required this.deleteSessionUseCase,
    this.activeSession,
    this.habitsNotifier,
    this.archiveSessionUseCase,
  });

  @override
  Widget build(BuildContext context) {
    final hasActiveSession = activeSession != null && habitsNotifier != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Мои сессии'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PastSessionsScreen(
                  sessionRepository: sessionRepository,
                  deleteSessionUseCase: deleteSessionUseCase,
                ),
              ),
            ),
          ),
          if (hasActiveSession) ...[
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Мои привычки'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HabitManagementPage(
                    habitsNotifier: habitsNotifier!,
                    sessionId: activeSession!.id,
                    readOnly: activeSession!.phase != 0,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.stop_circle_outlined, color: Colors.red),
              title: const Text('Завершить сессию', style: TextStyle(color: Colors.red)),
              onTap: () => _confirmEndSession(context),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmEndSession(BuildContext context) {
    final navigator = Navigator.of(context, rootNavigator: true);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Завершить сессию?'),
        content: const Text('Текущая сессия будет заархивирована. Действие необратимо.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await archiveSessionUseCase!.execute(activeSession!.id);
              navigator.pushReplacement(
                MaterialPageRoute(
                  builder: (_) => SessionSummaryScreen(
                    session: activeSession!,
                    deleteSessionUseCase: deleteSessionUseCase,
                    onComplete: () => navigator.popUntil((r) => r.isFirst),
                  ),
                ),
              );
            },
            child: const Text('Завершить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}