import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/profiles_repository.dart';

final class ProfilesRepositoryImpl implements ProfilesRepository {
  final SupabaseClient _client;

  ProfilesRepositoryImpl(this._client);

  @override
  Future<Map<String, String>?> fetchEncryptedKey(String userId) async {
    final response = await _client
        .from('profiles')
        .select('encrypted_master_key, master_key_nonce, master_key_salt')
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;

    return {
      'encrypted_master_key': response['encrypted_master_key'] as String,
      'master_key_nonce': response['master_key_nonce'] as String,
      'master_key_salt': response['master_key_salt'] as String,
    };
  }

  @override
  Future<void> saveEncryptedKey({
    required String userId,
    required String encryptedMasterKey,
    required String masterKeyNonce,
    required String masterKeySalt,
  }) async {
    await _client.from('profiles').upsert({
      'user_id': userId,
      'encrypted_master_key': encryptedMasterKey,
      'master_key_nonce': masterKeyNonce,
      'master_key_salt': masterKeySalt,
    });
  }
}