import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:dopamine_budget/core/crypto/data/sync_prefs.dart';

final class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client;

  static const _redirectUrl = 'dopaminebudget://auth/callback';
  static const _webClientId = '909378210278-ecl535nur0g5o22c9k1vqraapc2ulb02.apps.googleusercontent.com';

  AuthRepositoryImpl(this._client);

  @override
  Future<void> sendMagicLink(String email) async {
    await _client.auth.signInWithOtp(
      email: email,
      emailRedirectTo: _redirectUrl,
    );
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return AuthUser(userId: user.id, email: user.email ?? '');
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
    await _clearLocalData();
  }

  Future<void> _clearLocalData() async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'db.sqlite'));
      if (await file.exists()) await file.delete();
      // WAL и SHM файлы Drift:
      final wal = File(p.join(dbFolder.path, 'db.sqlite-wal'));
      final shm = File(p.join(dbFolder.path, 'db.sqlite-shm'));
      if (await wal.exists()) await wal.delete();
      if (await shm.exists()) await shm.delete();
    } catch (_) {}
    try {
      await SyncPrefs.clearOnSignOut(); // display_name и прочие SharedPreferences
    } catch (_) {}
  }

  @override
  Stream<AuthUser?> get authStateChanges {
    return _client.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      if (user == null) return null;
      return AuthUser(userId: user.id, email: user.email ?? '');
    });
  }
  @override
  Future<void> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      serverClientId: _webClientId,
      scopes: ['email'],
    );
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google Sign-In cancelled');

    final googleAuth = await googleUser.authentication;
    if (googleAuth.idToken == null) throw Exception('No ID token');

    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: googleAuth.idToken!,
      accessToken: googleAuth.accessToken,
    );
  }
}