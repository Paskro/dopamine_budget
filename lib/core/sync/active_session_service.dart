import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dopamine_budget/core/sync/sync_service.dart';

class ActiveSessionService {
  final SupabaseClient _client;
  StreamSubscription? _sub;
  final String deviceId;

  ActiveSessionService(this._client, {required this.deviceId});

  String get _uid => _client.auth.currentUser!.id;

  Future<void> activate() async {
    await _client.from('active_sessions').upsert({
      'user_id': _uid,
      'device_id': deviceId,
      'activated_at': DateTime.now().toIso8601String(),
    });
  }

  void startListening(BuildContext context) {
    try {
      _sub = _client
          .from('active_sessions')
          .stream(primaryKey: ['user_id'])
          .eq('user_id', _uid)
          .listen(
            (rows) async {
          if (rows.isEmpty) return;
          final remoteDeviceId = rows.first['device_id'] as String?;
          if (remoteDeviceId != null && remoteDeviceId != deviceId) {
            if (context.mounted) _showDisplacedDialog(context);
          }
        },
        onError: (e) => debugPrint('ActiveSession stream error: $e'),
      );
    } catch (e) {
      debugPrint('ActiveSession startListening error: $e');
    }
  }

  void _showDisplacedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Вход с другого устройства'),
        content: const Text('Сессия открыта на другом устройстве. Продолжить здесь?'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await activate();
            },
            child: const Text('Работать здесь'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _client.auth.signOut();
            },
            child: const Text('Выход'),
          ),
        ],
      ),
    );
  }

  void dispose() => _sub?.cancel();
}