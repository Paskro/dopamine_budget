import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../repositories/profiles_repository.dart';

/// Возвращает true если ключ уже существует (локально или скачан),
/// false если пользователь новый — нужно SetPin → генерация.
final class SyncMasterKeyUseCase {
  final ProfilesRepository _profiles;
  final FlutterSecureStorage _storage;

  static const _keyEncryptedMaster = 'db_enc_master';
  static const _keyMasterNonce = 'db_master_nonce';
  static const _keySalt = 'db_pbkdf2_salt';

  SyncMasterKeyUseCase(this._profiles, this._storage);

  Future<bool> execute(String userId) async {
    // Уже есть локально — ок
    final local = await _storage.read(key: _keyEncryptedMaster);
    if (local != null) return true;

    // Пробуем скачать с Supabase
    final remote = await _profiles.fetchEncryptedKey(userId);
    if (remote == null) return false; // новый пользователь

    // Записываем в SecureStorage (те же ключи что использует CryptoRepositoryImpl)
    await Future.wait([
      _storage.write(key: _keyEncryptedMaster, value: remote['encrypted_master_key']!),
      _storage.write(key: _keyMasterNonce, value: remote['master_key_nonce']!),
      _storage.write(key: _keySalt, value: remote['master_key_salt']!),
    ]);
    return true;
  }
}