import 'package:shared_preferences/shared_preferences.dart';

abstract final class SyncPrefs {
  static const _keySyncEnabled = 'sync_enabled';

  static Future<bool> isSyncEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySyncEnabled) ?? false;
  }

  static Future<void> setSyncEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySyncEnabled, value);
  }
}