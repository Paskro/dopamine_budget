// ==========================================
// БЛОК 1: КЛАСС СДВИГА ВИРТУАЛЬНОГО ВРЕМЕНИ
// ==========================================
class TimeProvider {
  static Duration _offset = Duration.zero;

  /// Возвращает текущее время (с учетом дебаг-сдвига для тестов)
  static DateTime get now => DateTime.now().add(_offset);

  /// Сдвинуть время приложения вперед (например, Duration(days: 1))
  static void addDuration(Duration duration) {
    _offset += duration;
    print('🚨 [TimeProvider]: Время сдвинуто! Виртуальное время: $now');
  }

  /// Сбросить виртуальное время на реальное системное
  static void reset() {
    _offset = Duration.zero;
    print('🚨 [TimeProvider]: Время сброшено на системное.');
  }
}