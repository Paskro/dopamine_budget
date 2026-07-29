import '../repositories/auth_repository.dart';

final class SendMagicLinkUseCase {
  final AuthRepository _repository;

  SendMagicLinkUseCase(this._repository);

  Future<void> execute(String email) => _repository.sendMagicLink(email.trim().toLowerCase());
}