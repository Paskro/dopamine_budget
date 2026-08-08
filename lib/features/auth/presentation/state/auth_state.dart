import 'package:flutter/foundation.dart';
import '../../domain/entities/auth_user.dart';

enum AuthStatus {
  loading,
  unauthenticated,      // показываем EmailScreen
  awaitingMagicLink,    // письмо отправлено
  authError,            // silent refresh провалился
  newUser,              // auth OK, MasterKey нет → SetPin
  existingUser,         // auth OK, MasterKey скачан → EnterPin
  authenticated,        // всё ок → RootGate
}

@immutable
class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  const AuthState.loading() : this(status: AuthStatus.loading);
  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);

  AuthState copyWith({AuthStatus? status, AuthUser? user, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}