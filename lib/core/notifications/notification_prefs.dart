import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPrefs {
  static const _shrinkHourKey = 'shrink_notify_hour';
  static const _shrinkMinuteKey = 'shrink_notify_minute';

  static Future<TimeOfDay> getShrinkNotifyTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_shrinkHourKey) ?? 8;
    final minute = prefs.getInt(_shrinkMinuteKey) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  static Future<void> setShrinkNotifyTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_shrinkHourKey, time.hour);
    await prefs.setInt(_shrinkMinuteKey, time.minute);
  }
}