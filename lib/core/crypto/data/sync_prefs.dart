// lib/core/crypto/data/sync_prefs.dart
import 'package:shared_preferences/shared_preferences.dart';

abstract final class SyncPrefs {
  static const _keySyncEnabled = 'sync_enabled';
  static const _keyOnboardingDone = 'onboarding_done';
  static const _keyDisplayName = 'user_display_name';

  static Future<bool> isSyncEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySyncEnabled) ?? false;
  }

  static Future<void> setSyncEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySyncEnabled, value);
  }

  static Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingDone) ?? false;
  }

  static Future<void> setOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingDone, true);
  }

  static Future<String?> getDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDisplayName);
  }

  static Future<void> setDisplayName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDisplayName, name);
  }

  static Future<void> clearOnSignOut() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_keySyncEnabled),
      prefs.remove(_keyOnboardingDone),
      prefs.remove(_keyDisplayName),
    ]);
  }
}