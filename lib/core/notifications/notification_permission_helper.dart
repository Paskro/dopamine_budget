import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationPermissionHelper {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      return await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, sound: true) ?? false;
    }
    if (Platform.isAndroid) {
      final impl = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await impl?.requestNotificationsPermission() ?? false;
    }
    return false;
  }

  static Future<bool> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;
    final impl = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await impl?.requestExactAlarmsPermission() ?? false;
  }
}