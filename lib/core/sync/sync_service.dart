import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import 'package:dopamine_budget/features/sessions/data/mappers/day_log_mapper.dart';
import 'package:drift/drift.dart';
import 'package:dopamine_budget/core/crypto/data/sync_prefs.dart';
import 'package:dopamine_budget/core/crypto/domain/repositories/crypto_repository.dart';
import 'package:dopamine_budget/core/crypto/domain/repositories/crypto_session_service.dart';
import 'package:dopamine_budget/core/crypto/domain/entities/encrypted_data_dto.dart';

class SyncService {
  final SupabaseClient _client;
  final AppDatabase _db;
  final CryptoRepository _crypto;
  final CryptoSessionService _session;

  SyncService(this._client, this._db, this._crypto, this._session);

  String get _uid => _client.auth.currentUser!.id;

  // ─── PUSH ────────────────────────────────────────────────────────────────

  Future<void> pushSessions() async {
    final rows = await _db.select(_db.sessionsTable).get();
    final payload = rows.map((r) => {
      'id': r.id,
      'user_id': _uid,
      'created_at': r.createdAt.toIso8601String(),
      'phase': r.phase,
      'avg_score': r.avgScore,
      'is_reviewed': r.isReviewed,
      'should_decrease': r.shouldDecrease,
      'calibration_days': r.calibrationDays,
      'control_started_at': r.controlStartedAt?.toIso8601String(),
      'base_shrinking_limit': r.baseShrinkingLimit,
      'shrinking_started_at': r.shrinkingStartedAt?.toIso8601String(),
      'decrease_percentage': r.decreasePercentage,
      'decrease_interval_days': r.decreaseIntervalDays,
      'shrunken_limit': r.shrunkenLimit,
      'updated_at': r.updatedAt.isEmpty
          ? DateTime.now().toIso8601String()
          : r.updatedAt,
      'is_deleted': r.isDeleted,
    }).toList();
    if (payload.isEmpty) return;
    await _client.from('sessions').upsert(payload);
  }

  Future<void> pushHabits() async {
    final rows = await (_db.select(_db.habitsTable)).get();
    final payload = <Map<String, dynamic>>[];
    for (final r in rows) {
      payload.add({
        'id': r.id,
        'user_id': _uid,
        'title': r.title,         // уже зашифрован в Drift
        'title_nonce': r.titleNonce, // уже есть в Drift
        'score_value': r.scoreValue,
        'is_archived': r.isArchived,
        'updated_at': r.updatedAt,
      });
    }
    if (payload.isEmpty) return;
    await _client.from('habits').upsert(payload);
  }

  Future<void> pushSessionHabits() async {
    final rows = await _db.select(_db.sessionHabitsTable).get();
    final payload = rows.map((r) => {
      'id': r.id,
      'user_id': _uid,
      'session_id': r.sessionId,
      'habit_id': r.habitId,
      'updated_at': r.updatedAt,
    }).toList();
    if (payload.isEmpty) return;
    await _client.from('session_habits').upsert(payload);
  }

  Future<void> pushHabitLogs() async {
    final rows = await _db.select(_db.habitLogsTable).get();
    final payload = rows.map((r) => {
      'id': r.id,
      'user_id': _uid,
      'habit_id': r.habitId,
      'session_id': r.sessionId,
      'timestamp': r.timestamp.toIso8601String(),
      'updated_at': r.updatedAt,
    }).toList();
    if (payload.isEmpty) return;
    await _client.from('habit_logs').upsert(payload);
  }

  Future<void> pushDays() async {
    final rows = await _db.select(_db.daysTable).get();
    final payload = rows.map((r) => {
      'user_id': _uid,
      'date': r.date,
      'session_id': r.sessionId,
      'is_broken_clicked': r.isBrokenClicked,
      'is_good_boy_clicked': r.isGoodBoyClicked,
      'day_status': r.dayStatus,
      'is_weekly_report_reviewed': r.isWeeklyReportReviewed,
      'updated_at': r.updatedAt,
    }).toList();
    if (payload.isEmpty) return;
    await _client.from('days').upsert(payload);
  }

  Future<void> pushShrinkingPeriods() async {
    final rows = await _db.select(_db.shrinkingPeriodsTable).get();
    final payload = rows.map((r) => {
      'id': r.id,
      'user_id': _uid,
      'session_id': r.sessionId,
      'started_at': r.startedAt,
      'ended_at': r.endedAt,
      'base_limit': r.baseLimit,
      'decrease_pct': r.decreasePct,
      'interval_days': r.intervalDays,
      'updated_at': r.updatedAt,
    }).toList();
    if (payload.isEmpty) return;
    await _client.from('shrinking_periods').upsert(payload);
  }

  Future<void> pushShrinkingReportsLog() async {
    final rows = await _db.select(_db.shrinkingReportsLogTable).get();
    final payload = rows.map((r) => {
      'id': r.id,
      'user_id': _uid,
      'session_id': r.sessionId,
      'period_week_start': r.periodWeekStart,
      'is_reviewed': r.isReviewed,
      'updated_at': r.updatedAt,
    }).toList();
    if (payload.isEmpty) return;
    await _client.from('shrinking_reports_log').upsert(payload);
  }

  Future<void> pushStreak() async {
    final rows = await _db.select(_db.streakTable).get();
    final payload = rows.map((r) => {
      'id': r.id,
      'user_id': _uid,
      'last_active_date': r.lastActiveDate,
      'current_multiplier': r.currentMultiplier,
      'previous_multiplier': r.previousMultiplier,
      'is_viewed': r.isViewed,
      'had_activity_yesterday': r.hadActivityYesterday,
      'updated_at': r.updatedAt.isEmpty
          ? DateTime.now().toIso8601String()
          : r.updatedAt,
    }).toList();
    if (payload.isEmpty) return;
    await _client.from('streak').upsert(payload);
  }

  // ─── PULL ─────────────────────────────────────────────────────────────────

  Future<void> pullAll() async {
    await Future.wait([
      _pullSessions(),
      _pullHabits(),
      _pullSessionHabits(),
      _pullHabitLogs(),
      _pullDays(),
      _pullShrinkingPeriods(),
      _pullShrinkingReportsLog(),
      _pullStreak(),
      pullUserProfile(),
    ]);
  }

  Future<void> _pullSessions() async {
    final remote = await _client
        .from('sessions')
        .select()
        .eq('user_id', _uid)
        .eq('is_deleted', false);

    for (final r in remote) {
      final localRow = await (_db.select(_db.sessionsTable)
        ..where((t) => t.id.equals(r['id'] as String)))
          .getSingleOrNull();

      final remoteUpdatedAt = DateTime.tryParse(r['updated_at'] as String? ?? '');
      final localUpdatedAt = localRow == null
          ? null
          : DateTime.tryParse(localRow.updatedAt);

      if (localRow != null &&
          remoteUpdatedAt != null &&
          localUpdatedAt != null &&
          !remoteUpdatedAt.isAfter(localUpdatedAt)) continue;

      await _db.into(_db.sessionsTable).insertOnConflictUpdate(
        SessionsTableCompanion(
          id: Value(r['id'] as String),
          createdAt: Value(DateTime.parse(r['created_at'] as String)),
          phase: Value(r['phase'] as int),
          avgScore: Value((r['avg_score'] as num?)?.toDouble()),
          isReviewed: Value(r['is_reviewed'] as bool? ?? false),
          shouldDecrease: Value(r['should_decrease'] as bool? ?? false),
          calibrationDays: Value(r['calibration_days'] as int? ?? 3),
          controlStartedAt: Value(r['control_started_at'] == null
              ? null
              : DateTime.parse(r['control_started_at'] as String)),
          baseShrinkingLimit: Value((r['base_shrinking_limit'] as num?)?.toDouble()),
          shrinkingStartedAt: Value(r['shrinking_started_at'] == null
              ? null
              : DateTime.parse(r['shrinking_started_at'] as String)),
          decreasePercentage: Value((r['decrease_percentage'] as num?)?.toDouble()),
          decreaseIntervalDays: Value(r['decrease_interval_days'] as int?),
          shrunkenLimit: Value((r['shrunken_limit'] as num?)?.toDouble()),
          updatedAt: Value(r['updated_at'] as String? ?? ''),
          isDeleted: Value(r['is_deleted'] as bool? ?? false),
          userId: Value(r['user_id'] as String?),
        ),
      );
    }
  }


  Future<void> _pullHabits() async {
    final key = _session.currentKey;
    final remote = await _client.from('habits').select().eq('user_id', _uid);

    for (final r in remote) {
      final localRow = await (_db.select(_db.habitsTable)
        ..where((t) => t.id.equals(r['id'] as String)))
          .getSingleOrNull();

      final remoteUpdatedAt = DateTime.tryParse(r['updated_at'] as String? ?? '');
      final localUpdatedAt = localRow == null
          ? null
          : DateTime.tryParse(localRow.updatedAt);

      if (localRow != null &&
          remoteUpdatedAt != null &&
          localUpdatedAt != null &&
          !remoteUpdatedAt.isAfter(localUpdatedAt)) continue;

      final nonce = r['title_nonce'] as String? ?? '';

      await _db.into(_db.habitsTable).insertOnConflictUpdate(
        HabitsTableCompanion(
          id: Value(r['id'] as String),
          title: Value(r['title'] as String),   // шифртекст как есть
          titleNonce: Value(nonce),              // сохраняем nonce
          scoreValue: Value(r['score_value'] as int),
          isArchived: Value(r['is_archived'] as bool? ?? false),
          updatedAt: Value(r['updated_at'] as String? ?? ''),
          userId: Value(r['user_id'] as String?),
        ),
      );
    }
  }

  Future<void> _pullSessionHabits() async {
    final remote = await _client
        .from('session_habits')
        .select()
        .eq('user_id', _uid);

    for (final r in remote) {
      final localRow = await (_db.select(_db.sessionHabitsTable)
        ..where((t) => t.id.equals(r['id'] as String)))
          .getSingleOrNull();

      final remoteUpdatedAt = DateTime.tryParse(r['updated_at'] as String? ?? '');
      final localUpdatedAt = localRow == null
          ? null
          : DateTime.tryParse(localRow.updatedAt);

      if (localRow != null &&
          remoteUpdatedAt != null &&
          localUpdatedAt != null &&
          !remoteUpdatedAt.isAfter(localUpdatedAt)) continue;

      await _db.into(_db.sessionHabitsTable).insertOnConflictUpdate(
        SessionHabitsTableCompanion(
          id: Value(r['id'] as String),
          sessionId: Value(r['session_id'] as String),
          habitId: Value(r['habit_id'] as String),
          updatedAt: Value(r['updated_at'] as String? ?? ''),
          userId: Value(r['user_id'] as String?),
        ),
      );
    }
  }

  Future<void> _pullHabitLogs() async {
    final remote = await _client
        .from('habit_logs')
        .select()
        .eq('user_id', _uid);

    for (final r in remote) {
      final localRow = await (_db.select(_db.habitLogsTable)
        ..where((t) => t.id.equals(r['id'] as String)))
          .getSingleOrNull();

      final remoteUpdatedAt = DateTime.tryParse(r['updated_at'] as String? ?? '');
      final localUpdatedAt = localRow == null
          ? null
          : DateTime.tryParse(localRow.updatedAt);

      if (localRow != null &&
          remoteUpdatedAt != null &&
          localUpdatedAt != null &&
          !remoteUpdatedAt.isAfter(localUpdatedAt)) continue;

      await _db.into(_db.habitLogsTable).insertOnConflictUpdate(
        HabitLogsTableCompanion(
          id: Value(r['id'] as String),
          habitId: Value(r['habit_id'] as String),
          sessionId: Value(r['session_id'] as String),
          timestamp: Value(DateTime.parse(r['timestamp'] as String)),
          updatedAt: Value(r['updated_at'] as String? ?? ''),
          userId: Value(r['user_id'] as String?),
        ),
      );
    }
  }

  Future<void> _pullDays() async {
    final remote = await _client
        .from('days')
        .select()
        .eq('user_id', _uid);

    for (final r in remote) {
      final dateStr = r['date'] as String;
      final localRow = await (_db.select(_db.daysTable)
        ..where((t) => t.date.equals(dateStr)))
          .getSingleOrNull();

      final remoteUpdatedAt = DateTime.tryParse(r['updated_at'] as String? ?? '');
      final localUpdatedAt = localRow == null
          ? null
          : DateTime.tryParse(localRow.updatedAt);

      if (localRow != null &&
          remoteUpdatedAt != null &&
          localUpdatedAt != null &&
          !remoteUpdatedAt.isAfter(localUpdatedAt)) continue;

      await _db.into(_db.daysTable).insertOnConflictUpdate(
        DaysTableCompanion(
          date: Value(dateStr),
          sessionId: Value(r['session_id'] as String),
          isBrokenClicked: Value(r['is_broken_clicked'] as bool? ?? false),
          isGoodBoyClicked: Value(r['is_good_boy_clicked'] as bool? ?? false),
          dayStatus: Value(r['day_status'] as String? ?? 'regular'),
          isWeeklyReportReviewed: Value(r['is_weekly_report_reviewed'] as bool? ?? false),
          updatedAt: Value(r['updated_at'] as String? ?? ''),
          userId: Value(r['user_id'] as String?),
        ),
      );
    }
  }

  Future<void> _pullShrinkingPeriods() async {
    final remote = await _client
        .from('shrinking_periods')
        .select()
        .eq('user_id', _uid);

    for (final r in remote) {
      final localRow = await (_db.select(_db.shrinkingPeriodsTable)
        ..where((t) => t.id.equals(r['id'] as String)))
          .getSingleOrNull();

      final remoteUpdatedAt = DateTime.tryParse(r['updated_at'] as String? ?? '');
      final localUpdatedAt = localRow == null
          ? null
          : DateTime.tryParse(localRow.updatedAt);

      if (localRow != null &&
          remoteUpdatedAt != null &&
          localUpdatedAt != null &&
          !remoteUpdatedAt.isAfter(localUpdatedAt)) continue;

      await _db.into(_db.shrinkingPeriodsTable).insertOnConflictUpdate(
        ShrinkingPeriodsTableCompanion(
          id: Value(r['id'] as String),
          sessionId: Value(r['session_id'] as String),
          startedAt: Value(r['started_at'] as String),
          endedAt: Value(r['ended_at'] as String?),
          baseLimit: Value((r['base_limit'] as num).toDouble()),
          decreasePct: Value((r['decrease_pct'] as num).toDouble()),
          intervalDays: Value(r['interval_days'] as int),
          updatedAt: Value(r['updated_at'] as String? ?? ''),
          userId: Value(r['user_id'] as String?),
        ),
      );
    }
  }

  Future<void> _pullShrinkingReportsLog() async {
    final remote = await _client
        .from('shrinking_reports_log')
        .select()
        .eq('user_id', _uid);

    for (final r in remote) {
      final localRow = await (_db.select(_db.shrinkingReportsLogTable)
        ..where((t) => t.id.equals(r['id'] as String)))
          .getSingleOrNull();

      final remoteUpdatedAt = DateTime.tryParse(r['updated_at'] as String? ?? '');
      final localUpdatedAt = localRow == null
          ? null
          : DateTime.tryParse(localRow.updatedAt);

      if (localRow != null &&
          remoteUpdatedAt != null &&
          localUpdatedAt != null &&
          !remoteUpdatedAt.isAfter(localUpdatedAt)) continue;

      await _db.into(_db.shrinkingReportsLogTable).insertOnConflictUpdate(
        ShrinkingReportsLogTableCompanion(
          id: Value(r['id'] as String),
          sessionId: Value(r['session_id'] as String),
          periodWeekStart: Value(r['period_week_start'] as String),
          isReviewed: Value(r['is_reviewed'] as bool? ?? false),
          updatedAt: Value(r['updated_at'] as String? ?? ''),
          userId: Value(r['user_id'] as String?),
        ),
      );
    }
  }
  Future<void> _pullStreak() async {
    final remote = await _client.from('streak').select().eq('user_id', _uid);

    for (final r in remote) {
      final lastActiveDate = r['last_active_date'] as String;
      final localRow = await (_db.select(_db.streakTable)
        ..where((t) => t.lastActiveDate.equals(lastActiveDate)))
          .getSingleOrNull();

      final remoteUpdatedAt = DateTime.tryParse(r['updated_at'] as String? ?? '');
      final localUpdatedAt = localRow == null
          ? null
          : DateTime.tryParse(localRow.updatedAt);

      if (localRow != null &&
          remoteUpdatedAt != null &&
          localUpdatedAt != null &&
          !remoteUpdatedAt.isAfter(localUpdatedAt)) continue;

      await _db.into(_db.streakTable).insertOnConflictUpdate(
        StreakTableCompanion(
          id: localRow == null ? const Value.absent() : Value(localRow.id),
          lastActiveDate: Value(lastActiveDate),
          currentMultiplier: Value((r['current_multiplier'] as num?)?.toDouble() ?? 1.0),
          previousMultiplier: Value((r['previous_multiplier'] as num?)?.toDouble() ?? 1.0),
          isViewed: Value(r['is_viewed'] as bool? ?? true),
          hadActivityYesterday: Value(r['had_activity_yesterday'] as bool? ?? false),
          updatedAt: Value(r['updated_at'] as String? ?? ''),
          userId: Value(r['user_id'] as String?),
        ),
      );
    }
  }

  Future<void> pushUserProfile() async {
    final name = await SyncPrefs.getDisplayName();
    if (name == null) return;
    await _client.from('user_profiles').upsert({
      'user_id': _uid,
      'display_name': name,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> pullUserProfile() async {
    final remote = await _client
        .from('user_profiles')
        .select()
        .eq('user_id', _uid)
        .maybeSingle();
    if (remote == null) return;
    final name = remote['display_name'] as String?;
    if (name != null && name.isNotEmpty) {
      await SyncPrefs.setDisplayName(name);
    }
  }
}