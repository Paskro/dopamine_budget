// time_provider.dart — ПОЛНАЯ ЗАМЕНА ФАЙЛА
import 'package:shared_preferences/shared_preferences.dart';

class TimeProvider {
  static Duration _offset = Duration.zero;
  static const _prefsKey = 'time_provider_offset_ms';

  static DateTime get now => DateTime.now().add(_offset);

  /// Вызвать один раз при старте приложения (до runApp), чтобы восстановить
  /// сдвиг времени, сохранённый в прошлой сессии.
  static Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_prefsKey) ?? 0;
    _offset = Duration(milliseconds: ms);
    print('🚨 [TimeProvider]: Восстановлен сдвиг времени: $_offset. Виртуальное время: $now');
  }

  static void addDuration(Duration duration) {
    _offset += duration;
    _persist();
    print('🚨 [TimeProvider]: Время сдвинуто! Виртуальное время: $now');
  }

  static void reset() {
    _offset = Duration.zero;
    _persist();
    print('🚨 [TimeProvider]: Время сброшено на системное.');
  }

  static void _persist() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt(_prefsKey, _offset.inMilliseconds);
    });
  }
}