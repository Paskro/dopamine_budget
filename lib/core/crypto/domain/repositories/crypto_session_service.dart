import '../entities/master_key.dart';

abstract interface class CryptoSessionService {
  MasterKey? get currentKey;
  bool get isUnlocked;
  void setKey(MasterKey key);
  void clear();
}