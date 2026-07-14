import 'package:vibration/vibration.dart';
import 'package:dopamine_budget/core/prefs/haptic_prefs.dart';

class HapticService {
  static bool _enabled = true;
  static bool _hasVibrator = false;

  static Future<void> init() async {
    _enabled = await HapticPrefs.isEnabled();
    _hasVibrator = (await Vibration.hasVibrator()) ?? false;
  }

  static void updateEnabled(bool value) {
    _enabled = value;
  }

  static void impact(int points) {
    if (!_enabled || !_hasVibrator) return;
    if (points <= 3) {
      Vibration.vibrate(duration: 80, amplitude: 100);
    } else if (points <= 7) {
      Vibration.vibrate(duration: 120, amplitude: 150);
    } else {
      Vibration.vibrate(duration: 200, amplitude: 255);
    }
  }

  static void light() {
    if (!_enabled || !_hasVibrator) return;
    Vibration.vibrate(duration: 30, amplitude: 60);
  }

  static void heavy() {
    if (!_enabled || !_hasVibrator) return;
    Vibration.vibrate(duration: 150, amplitude: 255);
  }

  static void selection() {
    if (!_enabled || !_hasVibrator) return;
    Vibration.vibrate(duration: 20, amplitude: 40);
  }
}