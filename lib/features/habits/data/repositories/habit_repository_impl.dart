import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:dopamine_budget/data/db/app_database.dart';
import 'package:dopamine_budget/features/habits/domain/entities/habit.dart';
import 'package:dopamine_budget/features/habits/domain/repositories/habit_repository.dart';
import 'package:dopamine_budget/core/crypto/domain/repositories/crypto_repository.dart';
import 'package:dopamine_budget/core/crypto/domain/repositories/crypto_session_service.dart';
import 'package:dopamine_budget/core/crypto/domain/entities/encrypted_data_dto.dart';
import 'package:flutter/foundation.dart';

class HabitRepositoryImpl implements HabitRepository {
  final AppDatabase _db;
  final CryptoRepository _crypto;
  final CryptoSessionService _session;
  final _uuid = const Uuid();

  HabitRepositoryImpl(this._db, this._crypto, this._session);

  @override
  Future<List<Habit>> getHabits() async {
    final rows = await (
        _db.select(_db.habitsTable)
          ..where((t) => t.isArchived.equals(false))
    ).get();
    return Future.wait(rows.map(_fromRow));
  }

  @override
  Future<void> addHabit(Habit habit) async {
    await addHabitAndGetId(habit);
  }

  @override
  Future<String?> addHabitAndGetId(Habit habit) async {
    try {
      final id = _uuid.v4();
      final key = _session.currentKey;
      String storedTitle = habit.title;
      String storedNonce = '';
      if (key != null) {
        final dto = await _crypto.encryptText(habit.title, key);
        storedTitle = dto.ciphertextBase64;
        storedNonce = dto.nonceBase64;
      }
      await _db.into(_db.habitsTable).insert(
        HabitsTableCompanion.insert(
          id: id,
          title: storedTitle,
          titleNonce: Value(storedNonce),
          emoji: Value(habit.emoji),
          scoreValue: habit.scoreValue,
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );
      return id;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    await (_db.update(_db.habitsTable)
      ..where((t) => t.id.equals(habit.id)))
        .write(HabitsTableCompanion(
      title: Value(habit.title),
      scoreValue: Value(habit.scoreValue),
      updatedAt: Value(DateTime.now().toIso8601String()),
    ));
  }

  @override
  Future<void> archiveHabit(String habitId) async {
    await _db.archiveHabit(habitId);
  }

  @override
  Future<void> toggleHabitSelection(String sessionId, String habitId) async {
    await _db.toggleHabitSelection(sessionId, habitId);
  }

  @override
  Future<List<String>> getSelectedHabitIdsForSession(String sessionId) async {
    return _db.getSelectedHabitIdsForSession(sessionId);
  }

  @override
  Future<List<Habit>> getHabitsForSession(String sessionId) async {
    final rows = await _db.getHabitsForSession(sessionId);
    return Future.wait(rows.map(_fromRow));
  }

  @override
  Stream<List<Habit>> watchHabits() {
    return _db.watchHabits().asyncMap(
          (rows) => Future.wait(rows.map(_fromRow)),
    );
  }
  @override
  Stream<List<String>> watchSelectedHabitIds(String sessionId) {
    return _db.watchSelectedHabitIds(sessionId);
  }

  Future<Habit> _fromRow(HabitsTableData row) async {
    final key = _session.currentKey;
    String title = row.title;
    final nonce = row.titleNonce;
    debugPrint('[_fromRow] id=${row.id} key=${key != null ? "HAS_KEY" : "NULL"} nonce="${nonce}" title_len=${title.length}');
    if (key != null && nonce.isNotEmpty) {
      try {
        final decrypted = await _crypto.decryptText(
          EncryptedDataDto(ciphertextBase64: title, nonceBase64: nonce),
          key,
        );
        debugPrint('[_fromRow] DECRYPTED: "$decrypted"');
        title = decrypted;
      } catch (e) {
        debugPrint('[_fromRow] DECRYPT ERROR: $e');
      }
    }
    return Habit(id: row.id, title: title, emoji: row.emoji, scoreValue: row.scoreValue);
  }


}