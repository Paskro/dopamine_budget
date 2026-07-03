import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/services.dart';

class NotificationScheduler {
  static const int _shrinkPushId = 2;
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(const InitializationSettings(android: android, iOS: ios));
    _initialized = true;
  }

  static Future<void> scheduleNextShrinkPush({
    required DateTime reportDay,
    required TimeOfDay notifyTime,
  }) async {
    try {
      final scheduled = tz.TZDateTime(
        tz.local,
        reportDay.year,
        reportDay.month,
        reportDay.day,
        notifyTime.hour,
        notifyTime.minute,
      );
      if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) return;

      await _plugin.zonedSchedule(
        _shrinkPushId,
        'Dopamine Budget',
        'Закончился период усыхания, хочешь изменить настройки?',
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'shrink_channel',
            'Усыхание',
            channelDescription: 'Уведомления об окончании периода усыхания',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
    } on PlatformException catch (e) {
      debugPrint('[NotificationScheduler] scheduleNextShrinkPush failed: $e');
    } catch (e) {
      debugPrint('[NotificationScheduler] unexpected error: $e');
    }
  }

  static Future<void> cancelShrinkPush() async {
    try {
      await _plugin.cancel(_shrinkPushId);
    } catch (e) {
      debugPrint('[NotificationScheduler] cancelShrinkPush failed: $e');
    }
  }
}