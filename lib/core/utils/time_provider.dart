import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimeProvider {
  static Duration _offset = Duration.zero;
  static const _prefsKey = 'time_provider_offset_ms';

  static DateTime get now => kDebugMode ? DateTime.now().add(_offset) : DateTime.now();

  static Future<void> restore() async {
    if (!kDebugMode) return;
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_prefsKey) ?? 0;
    _offset = Duration(milliseconds: ms);
    debugPrint('TimeProvider: восстановлен сдвиг $_offset');
  }

  static void addDay() => addDuration(const Duration(days: 1));

  static void addSixHours() => addDuration(const Duration(hours: 4));

  static void addDuration(Duration duration) {
    if (!kDebugMode) return;
    _offset += duration;
    _persist();
    debugPrint('TimeProvider: сдвиг на $duration, виртуальное время: $now');
  }

  static void reset() {
    if (!kDebugMode) return;
    _offset = Duration.zero;
    _persist();
    debugPrint('TimeProvider: сброшено на системное время.');
  }

  static void _persist() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt(_prefsKey, _offset.inMilliseconds);
    });
  }
}