// ЗАМЕНИТЬ весь файл:
import 'package:flutter/material.dart';
import 'package:dopamine_budget/core/crypto/domain/repositories/crypto_repository.dart';
import 'package:dopamine_budget/core/crypto/presentation/state/pin_notifier.dart';
import 'package:dopamine_budget/core/crypto/domain/entities/pin_state.dart';
import 'package:dopamine_budget/core/crypto/presentation/pages/enter_pin_screen.dart';
import 'package:dopamine_budget/core/sync/active_session_service.dart';
import 'package:dopamine_budget/features/auth/auth_module.dart';
import 'package:dopamine_budget/features/auth/presentation/state/auth_state.dart';
import 'package:dopamine_budget/features/auth/presentation/pages/magic_link_email_screen.dart';
import 'package:dopamine_budget/features/auth/presentation/pages/auth_flow_coordinator.dart';

class AppGate extends StatefulWidget {
  final PinNotifier pinNotifier;
  final CryptoRepository cryptoRepository;
  final AuthModule authModule;
  final ActiveSessionService activeSessionService;
  final Widget child;

  const AppGate({
    super.key,
    required this.pinNotifier,
    required this.cryptoRepository,
    required this.authModule,
    required this.activeSessionService,
    required this.child,
  });

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  bool _sessionActivated = false;

  Future<void> _activateIfNeeded() async {
    if (_sessionActivated) return;
    _sessionActivated = true;
    await widget.activeSessionService.activate();
    if (mounted) {
      widget.activeSessionService.startListening(context);
    }
  }

  @override
  void dispose() {
    widget.activeSessionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.authModule.authNotifier,
      builder: (context, _) {
        final authState = widget.authModule.authNotifier.state;

        switch (authState.status) {
          case AuthStatus.loading:
            return const Scaffold(body: Center(child: CircularProgressIndicator()));

          case AuthStatus.unauthenticated:
          case AuthStatus.awaitingMagicLink:
          case AuthStatus.authError:
            _sessionActivated = false;
            return MagicLinkEmailScreen(authNotifier: widget.authModule.authNotifier);

          case AuthStatus.newUser:
            return AuthFlowCoordinator(
              authNotifier: widget.authModule.authNotifier,
              pinNotifier: widget.pinNotifier,
              uploadMasterKey: widget.authModule.uploadMasterKeyUseCase,
            );

          case AuthStatus.existingUser:
            return ListenableBuilder(
              listenable: widget.pinNotifier,
              builder: (context, _) {
                final pinStatus = widget.pinNotifier.state.status;
                if (pinStatus == PinFlowStatus.loading) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }
                if (pinStatus == PinFlowStatus.unlocked) {
                  WidgetsBinding.instance.addPostFrameCallback((_) => _activateIfNeeded());
                  return widget.child;
                }
                return EnterPinScreen(
                  errorMessage: widget.pinNotifier.state.errorMessage,
                  onSubmit: widget.pinNotifier.submitUnlockPin,
                  onBiometric: () {},
                );
              },
            );

          case AuthStatus.authenticated:
            WidgetsBinding.instance.addPostFrameCallback((_) => _activateIfNeeded());
            return widget.child;
        }
      },
    );
  }
}