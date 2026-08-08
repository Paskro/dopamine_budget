import '../../domain/entities/master_key.dart';
import '../../domain/repositories/crypto_session_service.dart';

final class CryptoSessionServiceImpl implements CryptoSessionService {
  MasterKey? _key;

  @override
  MasterKey? get currentKey => _key;

  @override
  bool get isUnlocked => _key != null;

  @override
  void setKey(MasterKey key) => _key = key;

  @override
  void clear() => _key = null;
}