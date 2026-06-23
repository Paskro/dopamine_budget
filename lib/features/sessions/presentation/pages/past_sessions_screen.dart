import 'package:flutter/material.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/delete_session_use_case.dart';
import 'session_summary_screen.dart';

class PastSessionsScreen extends StatefulWidget {
  final SessionRepository sessionRepository;
  final DeleteSessionUseCase deleteSessionUseCase;

  const PastSessionsScreen({
    super.key,
    required this.sessionRepository,
    required this.deleteSessionUseCase,
  });

  @override
  State<PastSessionsScreen> createState() => _PastSessionsScreenState();
}

class _PastSessionsScreenState extends State<PastSessionsScreen> {
  late Future<List<Session>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.sessionRepository.getPastSessions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('История сессий')),
      body: FutureBuilder<List<Session>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final sessions = snapshot.data ?? [];
          if (sessions.isEmpty) {
            return const Center(child: Text('Завершённых сессий пока нет.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final s = sessions[index];
              final date =
                  '${s.createdAt.day.toString().padLeft(2, '0')}.${s.createdAt.month.toString().padLeft(2, '0')}.${s.createdAt.year}';
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text('Сессия от $date'),
                  subtitle: s.avgScore != null
                      ? Text('Средний балл: ${s.avgScore!.round()} XP')
                      : const Text('Калибровка не завершена'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SessionSummaryScreen(
                        session: s,
                        deleteSessionUseCase: widget.deleteSessionUseCase,
                        fromHistory: true,
                      ),
                    ),
                  ).then((_) => setState(() {
                    _future = widget.sessionRepository.getPastSessions();
                  })),
                ),
              );
            },
          );
        },
      ),
    );
  }
}