import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../repositories/profiles_repository.dart';

final class UploadMasterKeyUseCase {
  final ProfilesRepository _profiles;
  final FlutterSecureStorage _storage;

  static const _keyEncryptedMaster = 'db_enc_master';
  static const _keyMasterNonce = 'db_master_nonce';
  static const _keySalt = 'db_pbkdf2_salt';

  UploadMasterKeyUseCase(this._profiles, this._storage);

  Future<void> execute(String userId) async {
    final enc = await _storage.read(key: _keyEncryptedMaster);
    final nonce = await _storage.read(key: _keyMasterNonce);
    final salt = await _storage.read(key: _keySalt);

    if (enc == null || nonce == null || salt == null) {
      throw StateError('MasterKey not found in SecureStorage before upload');
    }

    await _profiles.saveEncryptedKey(
      userId: userId,
      encryptedMasterKey: enc,
      masterKeyNonce: nonce,
      masterKeySalt: salt,
    );
  }
}