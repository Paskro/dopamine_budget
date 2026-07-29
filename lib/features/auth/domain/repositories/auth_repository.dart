import '../entities/auth_user.dart';

abstract interface class AuthRepository {
  Future<void> sendMagicLink(String email);
  Future<AuthUser?> getCurrentUser();
  Future<void> signOut();
  Stream<AuthUser?> get authStateChanges;
}