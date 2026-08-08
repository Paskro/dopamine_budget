import 'package:flutter/material.dart';
import '_pin_scaffold.dart';

class SetPinScreen extends StatelessWidget {
  final String? errorMessage;
  final Future<void> Function(String pin) onSubmit;

  const SetPinScreen({super.key, this.errorMessage, required this.onSubmit});

  @override
  Widget build(BuildContext context) => PinScaffold(
    title: 'Создайте PIN',
    subtitle: 'Он защитит ваши данные',
    errorMessage: errorMessage,
    onComplete: onSubmit,
  );
}