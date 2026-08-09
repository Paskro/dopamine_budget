import 'package:home_widget/home_widget.dart';
import 'package:dopamine_budget/features/habits/domain/entities/habit.dart';

class WidgetDataService {
  static const _appGroupId = 'com.example.dopamine_budget';

  static Future<void> updateWidgetData({
    required List<Habit> activeHabits,
    required String dayStatus,
    required bool hasActiveSession,
    required double balance,
    required double dailyLimit,
  }) async {
    await HomeWidget.setAppGroupId(_appGroupId);

    final ids = activeHabits.map((h) => h.id).join(',');
    final emojis = activeHabits.map((h) => h.emoji).join(',');
    final costs = activeHabits.map((h) => h.scoreValue.toString()).join(',');

    await Future.wait([
      HomeWidget.saveWidgetData('habit_ids', ids),
      HomeWidget.saveWidgetData('habit_emojis', emojis),
      HomeWidget.saveWidgetData('habit_costs', costs),
      HomeWidget.saveWidgetData('day_status', dayStatus),
      HomeWidget.saveWidgetData('has_active_session', hasActiveSession ? '1' : '0'),
      HomeWidget.saveWidgetData('balance', balance.toStringAsFixed(1)),
      HomeWidget.saveWidgetData('daily_limit', dailyLimit.toStringAsFixed(1)),
      HomeWidget.saveWidgetData('widget_date', DateTime.now().toIso8601String().substring(0, 10)),
    ]);

    await HomeWidget.updateWidget(
      name: 'DopamineWidgetProvider',
      androidName: 'DopamineWidgetProvider',
    );
  }

  static Future<void> clearWidgetData() async {
    await HomeWidget.setAppGroupId(_appGroupId);
    await Future.wait([
      HomeWidget.saveWidgetData('habit_ids', ''),
      HomeWidget.saveWidgetData('has_active_session', '0'),
      HomeWidget.saveWidgetData('day_status', 'regular'),
    ]);
    await HomeWidget.updateWidget(
      name: 'DopamineWidgetProvider',
      androidName: 'DopamineWidgetProvider',
    );
  }
}
