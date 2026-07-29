import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dopamine_budget/core/crypto/data/sync_prefs.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/send_magic_link_usecase.dart';
import '../../domain/usecases/sync_master_key_usecase.dart';
import 'auth_state.dart';

final class AuthNotifier extends ChangeNotifier {
  final AuthRepository _authRepository;
  final SendMagicLinkUseCase _sendMagicLink;
  final SyncMasterKeyUseCase _syncMasterKey;
  final FlutterSecureStorage _storage;
  final Future<void> Function()? onPullAll;

  static const _keyUserId = 'supabase_user_id';

  StreamSubscription<AuthUser?>? _authSub;

  AuthState _state = const AuthState.loading();
  AuthState get state => _state;

  AuthNotifier({
    required AuthRepository authRepository,
    required SendMagicLinkUseCase sendMagicLink,
    required SyncMasterKeyUseCase syncMasterKey,
    required FlutterSecureStorage storage,
    this.onPullAll,
  })  : _authRepository = authRepository,
        _sendMagicLink = sendMagicLink,
        _syncMasterKey = syncMasterKey,
        _storage = storage {
    _init();
  }

  void _init() {
    _authSub = _authRepository.authStateChanges.listen(
      _onAuthStateChanged,
      onError: (_) => _setUnauthenticated(),
    );
  }

  Future<void> _onAuthStateChanged(AuthUser? user) async {
    if (user == null) {
      await _storage.delete(key: _keyUserId);
      await SyncPrefs.setSyncEnabled(false);
      _emit(const AuthState.unauthenticated());
      return;
    }

    await _storage.write(key: _keyUserId, value: user.userId);
    await SyncPrefs.setSyncEnabled(true);

    final hasKey = await _syncMasterKey.execute(user.userId);

    if (hasKey) {
      try {
        await onPullAll?.call();
      } catch (_) {
        // pull не блокирует авторизацию
      }
    }

    _emit(AuthState(
      status: hasKey ? AuthStatus.existingUser : AuthStatus.newUser,
      user: user,
    ));
  }

  Future<void> sendMagicLink(String email) async {
    _emit(_state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      await _sendMagicLink.execute(email);
      _emit(_state.copyWith(status: AuthStatus.awaitingMagicLink));
    } catch (e) {
      _emit(_state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Не удалось отправить письмо. Проверьте email.',
      ));
    }
  }

  /// Вызывается из AppGate после успешного SetPin + Upload
  void markAuthenticated() {
    _emit(_state.copyWith(status: AuthStatus.authenticated));
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    await _storage.delete(key: _keyUserId);
    await SyncPrefs.setSyncEnabled(false);
    // EncryptedMasterKey в SecureStorage НЕ удаляем (по решению из п.14)
    _emit(const AuthState.unauthenticated());
  }

  void _setUnauthenticated() => _emit(const AuthState.unauthenticated());

  void _emit(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}