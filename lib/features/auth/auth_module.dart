import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/profiles_repository_impl.dart';
import 'domain/usecases/send_magic_link_usecase.dart';
import 'domain/usecases/sync_master_key_usecase.dart';
import 'domain/usecases/upload_master_key_usecase.dart';
import 'presentation/state/auth_notifier.dart';

final class AuthModule {
  final AuthNotifier authNotifier;
  final UploadMasterKeyUseCase uploadMasterKeyUseCase;

  AuthModule._({required this.authNotifier, required this.uploadMasterKeyUseCase});

  static AuthModule create(
      FlutterSecureStorage storage, {
        Future<void> Function()? onPullAll,
        Future<void> Function()? onAfterPull,
      }) {
    final client = Supabase.instance.client;
    final authRepo = AuthRepositoryImpl(client);
    final profilesRepo = ProfilesRepositoryImpl(client);
    final sendMagicLink = SendMagicLinkUseCase(authRepo);
    final syncMasterKey = SyncMasterKeyUseCase(profilesRepo, storage);
    final uploadMasterKey = UploadMasterKeyUseCase(profilesRepo, storage);

    final authNotifier = AuthNotifier(
      authRepository: authRepo,
      sendMagicLink: sendMagicLink,
      syncMasterKey: syncMasterKey,
      storage: storage,
      onPullAll: onPullAll,
      onAfterPull: onAfterPull,
    );

    return AuthModule._(
      authNotifier: authNotifier,
      uploadMasterKeyUseCase: uploadMasterKey,
    );
  }
}