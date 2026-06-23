import 'package:flutter/material.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/delete_session_use_case.dart';
import 'past_sessions_screen.dart';

class ProfileScreen extends StatelessWidget {
  final SessionRepository sessionRepository;
  final DeleteSessionUseCase deleteSessionUseCase;

  const ProfileScreen({
    super.key,
    required this.sessionRepository,
    required this.deleteSessionUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('История сессий'),
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
        ],
      ),
    );
  }
}