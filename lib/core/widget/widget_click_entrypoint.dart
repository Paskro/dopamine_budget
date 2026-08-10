import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import 'package:dopamine_budget/core/utils/time_provider.dart';

const _channel = MethodChannel('com.example.dopamine_budget/widget_click');

@pragma('vm:entry-point')
Future<void> widgetClickEntrypoint() async {
  WidgetsFlutterBinding.ensureInitialized();
  _channel.setMethodCallHandler((call) async {
    if (call.method == 'logHabitClick') {
      final args = call.arguments as Map;
      final habitId   = args['habitId']   as String;
      final scoreCost = args['scoreCost'] as int;

      try {
        final db = AppDatabase.instance;
        await db.transaction(() async {
          final session = await (db.select(db.sessionsTable)
            ..where((t) => t.phase.isSmallerThanValue(2))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(1))
              .getSingleOrNull();
          if (session == null) return;

          final now = TimeProvider.now;
          final dateStr = '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';

          final dayRow = await (db.select(db.daysTable)
            ..where((t) => t.date.equals(dateStr)))
              .getSingleOrNull();

          if (dayRow != null && dayRow.dayStatus == 'broken') return;

          await db.into(db.habitLogsTable).insert(
            HabitLogsTableCompanion.insert(
              id: const Uuid().v4(),
              habitId: habitId,
              sessionId: session.id,
              timestamp: now,
              updatedAt: now.toIso8601String(),
            ),
          );
        });
      } catch (_) {}
    }
  });
}
