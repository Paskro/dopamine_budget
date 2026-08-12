import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:home_widget/home_widget.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.data['type'] == 'widget_refresh') {
    await HomeWidget.updateWidget(
      name: 'DopamineWidgetProvider',
      androidName: 'DopamineWidgetProvider',
    );
  }
}
