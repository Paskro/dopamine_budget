import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/encrypted_data_dto.dart';
import '../../domain/entities/master_key.dart';
import '../../domain/repositories/crypto_repository.dart';

final class CryptoRepositoryImpl implements CryptoRepository {
  CryptoRepositoryImpl(this._storage);

  final FlutterSecureStorage _storage;

  static const _keyMasterRaw = 'master_key_raw';
  static const _keyEncryptedMaster = 'db_enc_master';
  static const _keyMasterNonce = 'db_master_nonce';
  static const _keySalt = 'db_pbkdf2_salt';



  static const _pbkdf2Iterations = 100000;
  static const _keyLengthBytes = 32; // 256 bit

  final _aesGcm = AesGcm.with256bits();
  final _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: _pbkdf2Iterations,
    bits: _keyLengthBytes * 8,
  );
  final _secureRandom = Random.secure();

  // ── KDF ────────────────────────────────────────────────────────────────────

  Future<SecretKey> _deriveKeyFromPin(String pin, Uint8List salt) async {
    final pinBytes = utf8.encode(pin);
    return _pbkdf2.deriveKey(
      secretKey: SecretKey(pinBytes),
      nonce: salt,
    );
  }


  // ── Public API ─────────────────────────────────────────────────────────────

  @override
  Future<bool> isMasterKeyInitialized() async {
    final value = await _storage.read(key: _keyEncryptedMaster);
    return value != null;
  }

  @override
  Future<void> generateAndStoreMasterKey(String pin) async {
    // 1. Генерируем MasterKey
    final masterKeyBytes = Uint8List.fromList(
      await _aesGcm.newSecretKey().then((k) => k.extractBytes()),
    );

    // 2. Генерируем соль
    final salt = Uint8List.fromList(
      List<int>.generate(16, (_) => _secureRandom.nextInt(256)),
    );

    // 3. Деривируем PinDerivedKey
    final pinDerivedKey = await _deriveKeyFromPin(pin, salt);

    // 4. Шифруем MasterKey пин-ключом
    final nonce = _aesGcm.newNonce();
    final secretBox = await _aesGcm.encrypt(
      masterKeyBytes,
      secretKey: pinDerivedKey,
      nonce: nonce,
    );

    // 5. Сохраняем в SecureStorage
    await Future.wait([
      _storage.write(
        key: _keyEncryptedMaster,
        value: base64Encode(secretBox.cipherText + secretBox.mac.bytes),
      ),
      _storage.write(
        key: _keyMasterNonce,
        value: base64Encode(nonce),
      ),
      _storage.write(
        key: _keySalt,
        value: base64Encode(salt),
      ),
    ]);
  }

  @override
  Future<MasterKey?> unlockMasterKey(String pin) async {
    final encB64 = await _storage.read(key: _keyEncryptedMaster);
    final nonceB64 = await _storage.read(key: _keyMasterNonce);
    final saltB64 = await _storage.read(key: _keySalt);

    if (encB64 == null || nonceB64 == null || saltB64 == null) return null;

    final salt = base64Decode(saltB64);
    final pinDerivedKey = await _deriveKeyFromPin(pin, salt);

    final encBytes = base64Decode(encB64);
    // Последние 16 байт — MAC (AES-GCM tag)
    final cipherText = encBytes.sublist(0, encBytes.length - 16);
    final mac = Mac(encBytes.sublist(encBytes.length - 16));
    final nonce = base64Decode(nonceB64);

    try {
      final clearBytes = await _aesGcm.decrypt(
        SecretBox(cipherText, nonce: nonce, mac: mac),
        secretKey: pinDerivedKey,
      );
      return MasterKey(Uint8List.fromList(clearBytes));
    } on SecretBoxAuthenticationError {
      // Неверный PIN — MAC не совпал
      return null;
    }
  }

  @override
  Future<EncryptedDataDto> encryptText(String plainText, MasterKey key) async {
    final secretKey = SecretKey(key.bytes);
    final nonce = _aesGcm.newNonce();
    final secretBox = await _aesGcm.encrypt(
      utf8.encode(plainText),
      secretKey: secretKey,
      nonce: nonce,
    );
    return EncryptedDataDto(
      ciphertextBase64: base64Encode(
          secretBox.cipherText + secretBox.mac.bytes),
      nonceBase64: base64Encode(nonce),
    );
  }

  @override
  Future<String> decryptText(EncryptedDataDto data, MasterKey key) async {
    final secretKey = SecretKey(key.bytes);
    final encBytes = base64Decode(data.ciphertextBase64);
    final cipherText = encBytes.sublist(0, encBytes.length - 16);
    final mac = Mac(encBytes.sublist(encBytes.length - 16));
    final nonce = base64Decode(data.nonceBase64);

    final clearBytes = await _aesGcm.decrypt(
      SecretBox(cipherText, nonce: nonce, mac: mac),
      secretKey: secretKey,
    );
    return utf8.decode(clearBytes);
  }
  @override
  Future<void> saveMasterKeyRaw(Uint8List keyBytes) async {
    await _storage.write(
      key: _keyMasterRaw,
      value: base64Encode(keyBytes),
    );
  }
  @override
  Future<MasterKey?> loadMasterKeyRaw() async {
    final value = await _storage.read(key: _keyMasterRaw);
    if (value == null) return null;
    return MasterKey(base64Decode(value));
  }

}
