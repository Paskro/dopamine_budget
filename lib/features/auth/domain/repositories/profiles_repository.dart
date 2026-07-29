abstract interface class ProfilesRepository {
  /// Загружает encryptedMasterKey + nonce + salt из Supabase profiles.
  /// Возвращает null если записи нет (новый пользователь).
  Future<Map<String, String>?> fetchEncryptedKey(String userId);

  /// Сохраняет encryptedMasterKey + nonce + salt в Supabase profiles.
  Future<void> saveEncryptedKey({
    required String userId,
    required String encryptedMasterKey,
    required String masterKeyNonce,
    required String masterKeySalt,
  });
}