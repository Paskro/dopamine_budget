import 'dart:typed_data';
import '../entities/encrypted_data_dto.dart';
import '../entities/master_key.dart';

abstract interface class CryptoRepository {
  /// Генерирует новый случайный MasterKey и сохраняет зашифрованный блоб + соль.
  Future<void> generateAndStoreMasterKey(String pin);

  /// Разблокирует MasterKey из SecureStorage по PIN-коду.
  /// Возвращает null если PIN неверный или ключа нет.
  Future<MasterKey?> unlockMasterKey(String pin);

  /// Возвращает true если MasterKey уже создан (пользователь уже устанавливал PIN).
  Future<bool> isMasterKeyInitialized();

  Future<EncryptedDataDto> encryptText(String plainText, MasterKey key);
  Future<String> decryptText(EncryptedDataDto data, MasterKey key);

  Future<void> saveMasterKeyRaw(Uint8List keyBytes);
  Future<MasterKey?> loadMasterKeyRaw();
}