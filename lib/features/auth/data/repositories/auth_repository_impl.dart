import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

final class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client;

  static const _redirectUrl = 'dopaminebudget://auth/callback';

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
  }

  @override
  Stream<AuthUser?> get authStateChanges {
    return _client.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      if (user == null) return null;
      return AuthUser(userId: user.id, email: user.email ?? '');
    });
  }
}