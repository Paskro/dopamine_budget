import 'package:flutter/material.dart';
import 'package:dopamine_budget/core/crypto/presentation/state/pin_notifier.dart';
import 'package:dopamine_budget/core/crypto/domain/entities/pin_state.dart';
import 'set_pin_screen.dart';
import 'confirm_pin_screen.dart';
import 'enter_pin_screen.dart';

class PinGate extends StatelessWidget {
  final PinNotifier pinNotifier;
  final Widget child; // RootGate

  const PinGate({super.key, required this.pinNotifier, required this.child});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: pinNotifier,
      builder: (context, _) {
        final state = pinNotifier.state;

        return switch (state.status) {
          PinFlowStatus.loading => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          PinFlowStatus.needsSetup => SetPinScreen(
            errorMessage: state.errorMessage,
            onSubmit: (pin) async => pinNotifier.submitFirstPin(pin),
          ),
          PinFlowStatus.needsConfirm => ConfirmPinScreen(
            errorMessage: state.errorMessage,
            onSubmit: pinNotifier.submitConfirmPin,
            onBack: pinNotifier.cancelConfirm, // сброс через невалидный вызов
          ),
          PinFlowStatus.needsUnlock => EnterPinScreen(
            errorMessage: state.errorMessage,
            onSubmit: pinNotifier.submitUnlockPin,
            onBiometric: () => _handleBiometric(context),
          ),
          PinFlowStatus.unlocked => child,
          PinFlowStatus.error => child, // не достижимо — error всегда с конкретным status
        };
      },
    );
  }

  void _handleBiometric(BuildContext context) {
    // заглушка — реализуется в следующем спринте
  }
}