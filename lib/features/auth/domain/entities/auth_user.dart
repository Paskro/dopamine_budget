import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final String userId;
  final String email;

  const AuthUser({required this.userId, required this.email});
}