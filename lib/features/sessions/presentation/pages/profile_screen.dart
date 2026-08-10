import 'package:flutter/material.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/delete_session_use_case.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/archive_session_use_case.dart';
import 'package:dopamine_budget/features/habits/presentation/state/habits_notifier.dart';
import 'package:dopamine_budget/features/habits/presentation/pages/habit_management_page.dart';
import 'package:dopamine_budget/features/sessions/presentation/pages/session_summary_screen.dart';
import 'past_sessions_screen.dart';
import 'package:dopamine_budget/core/prefs/haptic_prefs.dart';
import 'package:dopamine_budget/core/utils/haptic_service.dart';
import 'package:flutter/services.dart';
import 'package:dopamine_budget/features/auth/presentation/state/auth_notifier.dart';

class ProfileScreen extends StatelessWidget {
  final SessionRepository sessionRepository;
  final DeleteSessionUseCase deleteSessionUseCase;
  final Session? activeSession;
  final HabitsNotifier? habitsNotifier;
  final ArchiveSessionUseCase? archiveSessionUseCase;
  final AuthNotifier? authNotifier;

  const ProfileScreen({
    super.key,
    required this.sessionRepository,
    required this.deleteSessionUseCase,
    this.activeSession,
    this.habitsNotifier,
    this.archiveSessionUseCase,
    this.authNotifier,
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
          _HapticToggleTile(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Выйти из аккаунта', style: TextStyle(color: Colors.red)),
            onTap: () => _confirmSignOut(context),
          ),
          ElevatedButton(
            onPressed: () async {
              final bool result = await SystemChannels.platform.invokeMethod('HapticFeedback.vibrate', 'HapticFeedbackType.vibrate');
              debugPrint('Haptic result: $result');
            },
            child: const Text('TEST VIBRO'),
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
                    readOnly: false,
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

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        content: const Text('Данные на устройстве сохранятся. Для повторного входа потребуется email.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await authNotifier?.signOut();
            },
            child: const Text('Выйти', style: TextStyle(color: Colors.red)),
          ),
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
class _HapticToggleTile extends StatefulWidget {
  @override
  State<_HapticToggleTile> createState() => _HapticToggleTileState();
}

class _HapticToggleTileState extends State<_HapticToggleTile> {
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    HapticPrefs.isEnabled().then((v) {
      if (mounted) setState(() => _enabled = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: const Icon(Icons.vibration),
      title: const Text('Виброотклик'),
      value: _enabled,
      onChanged: (v) {
        setState(() => _enabled = v);
        HapticPrefs.setEnabled(v);
        HapticService.updateEnabled(v);
      },
    );
  }
}

