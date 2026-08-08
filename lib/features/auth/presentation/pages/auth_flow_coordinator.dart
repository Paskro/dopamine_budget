import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dopamine_budget/core/crypto/data/repositories/crypto_repository_impl.dart';
import 'package:dopamine_budget/core/crypto/presentation/pages/set_pin_screen.dart';
import 'package:dopamine_budget/core/crypto/presentation/pages/confirm_pin_screen.dart';
import 'package:dopamine_budget/core/crypto/presentation/state/pin_notifier.dart';
import 'package:dopamine_budget/features/auth/domain/usecases/upload_master_key_usecase.dart';
import '../state/auth_notifier.dart';
import '../state/auth_state.dart';

class AuthFlowCoordinator extends StatefulWidget {
  final AuthNotifier authNotifier;
  final PinNotifier pinNotifier;
  final UploadMasterKeyUseCase uploadMasterKey;
  final VoidCallback? onComplete; // ← добавить

  const AuthFlowCoordinator({
    super.key,
    required this.authNotifier,
    required this.pinNotifier,
    required this.uploadMasterKey,
    this.onComplete, // ← добавить
  });

  @override
  State<AuthFlowCoordinator> createState() => _AuthFlowCoordinatorState();
}
class _AuthFlowCoordinatorState extends State<AuthFlowCoordinator> {
  String? _firstPin;
  String? _pinError;
  bool _isUploading = false;

  void _onSetPin(String pin) {
    debugPrint('SET PIN CALLED: $pin');
    setState(() {
      _firstPin = pin;
      _pinError = null;
    });
  }

  Future<void> _onConfirmPin(String pin) async {
    if (pin != _firstPin) {
      setState(() => _pinError = 'PIN не совпадает. Попробуйте ещё раз.');
      return;
    }

    setState(() => _isUploading = true);
    try {
      final userId = widget.authNotifier.state.user!.userId;
      widget.pinNotifier.submitFirstPin(pin);
      await widget.pinNotifier.submitConfirmPin(pin);
      await widget.uploadMasterKey.execute(userId);
      widget.authNotifier.markAuthenticated();
      widget.onComplete?.call();
      // _isUploading не сбрасываем — виджет уйдёт со стека через authState
    } catch (e, stack) {
      debugPrint('CONFIRM ERROR: $e');
      debugPrint('STACK: $stack');
      if (mounted) {
        setState(() {
          _pinError = 'Ошибка сохранения. Попробуйте ещё раз.';
          _firstPin = null;
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isUploading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_firstPin == null) {
      return SetPinScreen(onSubmit: (pin) async => _onSetPin(pin));
    }

    return ConfirmPinScreen(
      errorMessage: _pinError,
      onSubmit: _onConfirmPin,
      onBack: () => setState(() {
        _firstPin = null;
        _pinError = null;
      }),
    );
  }
}