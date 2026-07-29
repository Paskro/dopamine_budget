import 'package:flutter/material.dart';
import '_pin_scaffold.dart';

class ConfirmPinScreen extends StatelessWidget {
  final String? errorMessage;
  final Future<void> Function(String pin) onSubmit;
  final VoidCallback onBack;

  const ConfirmPinScreen({
    super.key,
    this.errorMessage,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) => PinScaffold(
    title: 'Повторите PIN',
    subtitle: 'Введите PIN ещё раз для подтверждения',
    errorMessage: errorMessage,
    onComplete: onSubmit,
    leadingAction: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: onBack,
    ),
  );
}