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
    required int sessionPhase,
    required String sessionId,
    required int spentToday,
  }) async {
    await HomeWidget.setAppGroupId(_appGroupId);

    final ids    = activeHabits.map((h) => h.id).join(',');
    final emojis = activeHabits.map((h) => h.emoji).join(',');
    final costs  = activeHabits.map((h) => h.scoreValue.toString()).join(',');

    await Future.wait([
      HomeWidget.saveWidgetData('habit_ids',          ids),
      HomeWidget.saveWidgetData('habit_emojis',       emojis),
      HomeWidget.saveWidgetData('habit_costs',        costs),
      HomeWidget.saveWidgetData('day_status',         dayStatus),
      HomeWidget.saveWidgetData('has_active_session', hasActiveSession ? '1' : '0'),
      HomeWidget.saveWidgetData('balance',            balance.toStringAsFixed(0)),
      HomeWidget.saveWidgetData('daily_limit',        dailyLimit.toStringAsFixed(0)),
      HomeWidget.saveWidgetData('session_phase',      sessionPhase.toString()),
      HomeWidget.saveWidgetData('session_id',         sessionId),
      HomeWidget.saveWidgetData('spent_today',        spentToday.toString()),
      HomeWidget.saveWidgetData('widget_date',        DateTime.now().toIso8601String().substring(0, 10)),
      HomeWidget.saveWidgetData('app_active',         '0'),
    ]);

    await HomeWidget.updateWidget(
      name:        'DopamineWidgetProvider',
      androidName: 'DopamineWidgetProvider',
    );
  }

  static Future<void> setAppActive(bool active) async {
    await HomeWidget.setAppGroupId(_appGroupId);
    await HomeWidget.saveWidgetData('app_active', active ? '1' : '0');
    await HomeWidget.updateWidget(
      name:        'DopamineWidgetProvider',
      androidName: 'DopamineWidgetProvider',
    );
  }

  static Future<void> clearWidgetData() async {
    await HomeWidget.setAppGroupId(_appGroupId);
    await Future.wait([
      HomeWidget.saveWidgetData('habit_ids',          ''),
      HomeWidget.saveWidgetData('has_active_session', '0'),
      HomeWidget.saveWidgetData('day_status',         'regular'),
      HomeWidget.saveWidgetData('session_phase',      '0'),
      HomeWidget.saveWidgetData('session_id',         ''),
      HomeWidget.saveWidgetData('spent_today',        '0'),
      HomeWidget.saveWidgetData('app_active',         '0'),
    ]);
    await HomeWidget.updateWidget(
      name:        'DopamineWidgetProvider',
      androidName: 'DopamineWidgetProvider',
    );
  }
}
