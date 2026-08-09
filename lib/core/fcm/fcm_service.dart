import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FcmService {
  final FlutterSecureStorage _secureStorage;
  final SupabaseClient _client;

  static const _keyFcmToken = 'fcm_token';
  static const _keyDeviceId = 'device_id';

  FcmService(this._secureStorage, this._client);

  Future<void> init() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(alert: false, badge: false, sound: false);
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    final token = await messaging.getToken();
    if (token != null) {
      await _registerToken(token);
    }

    messaging.onTokenRefresh.listen(_registerToken);
  }

  Future<void> _registerToken(String token) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final stored = await _secureStorage.read(key: _keyFcmToken);
    if (stored == token) return;

    final deviceId = await _secureStorage.read(key: _keyDeviceId);
    if (deviceId == null) return;

    await _client.from('user_devices').upsert({
      'user_id': userId,
      'device_id': deviceId,
      'fcm_token': token,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,device_id');

    await _secureStorage.write(key: _keyFcmToken, value: token);
  }

  Future<void> notifyOtherDevices({Map<String, String>? data}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final deviceId = await _secureStorage.read(key: _keyDeviceId);

    try {
      await _client.functions.invoke(
        'notify-devices',
        body: {
          'user_id': userId,
          'exclude_device_id': deviceId,
          'data': data ?? {'type': 'widget_refresh'},
        },
      );
    } catch (_) {}
  }
}
