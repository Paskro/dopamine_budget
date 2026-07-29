import 'package:flutter/material.dart';
import '_pin_scaffold.dart';

class EnterPinScreen extends StatelessWidget {
  final String? errorMessage;
  final Future<void> Function(String pin) onSubmit;
  final VoidCallback onBiometric;

  const EnterPinScreen({
    super.key,
    this.errorMessage,
    required this.onSubmit,
    required this.onBiometric,
  });

  @override
  Widget build(BuildContext context) => PinScaffold(
    title: 'Введите PIN',
    errorMessage: errorMessage,
    onComplete: onSubmit,
    bottomAction: TextButton.icon(
      onPressed: onBiometric,
      icon: const Icon(Icons.fingerprint),
      label: const Text('Войти по биометрии'),
    ),
  );
}