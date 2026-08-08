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
import 'package:dopamine_budget/core/crypto/data/sync_prefs.dart';
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
  bool? _syncEnabled;

  @override
  void initState() {
    super.initState();
    _loadSyncEnabled();
    widget.authModule.authNotifier.addListener(_onAuthChanged);
  }

  Future<void> _loadSyncEnabled() async {
    final val = await SyncPrefs.isSyncEnabled();
    if (mounted) setState(() => _syncEnabled = val);
  }

  void _onAuthChanged() async {
    final status = widget.authModule.authNotifier.state.status;
    if (status == AuthStatus.loading) return;
    if (status == AuthStatus.unauthenticated ||
        status == AuthStatus.authError) {
      if (mounted) setState(() => _syncEnabled = false);
      return;
    }
    final val = await SyncPrefs.isSyncEnabled();
    if (mounted) setState(() => _syncEnabled = val);
  }

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
    widget.authModule.authNotifier.removeListener(_onAuthChanged);
    widget.activeSessionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_syncEnabled == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A2421),
        body: SizedBox.shrink(),
      );
    }
    if (_syncEnabled == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _activateIfNeeded());
      return widget.child;
    }
    return _buildAuthGate();
  }

  Widget _buildAuthGate() {
    return ListenableBuilder(
      listenable: widget.authModule.authNotifier,
      builder: (context, _) {
        final authState = widget.authModule.authNotifier.state;
        switch (authState.status) {
          case AuthStatus.loading:
            return const Scaffold(
              backgroundColor: Color(0xFF1A2421),
              body: Center(child: CircularProgressIndicator()),
            );
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
              onComplete: () => _activateIfNeeded(),
            );
          case AuthStatus.existingUser:
          // Если PinNotifier уже unlocked до подписки — активируем сразу
            if (widget.pinNotifier.state.status == PinFlowStatus.unlocked) {
              WidgetsBinding.instance.addPostFrameCallback((_) => _activateIfNeeded());
              return widget.child;
            }
            return ListenableBuilder(
              listenable: widget.pinNotifier,
              builder: (context, _) {
                final pinStatus = widget.pinNotifier.state.status;
                if (pinStatus == PinFlowStatus.loading) {
                  return const Scaffold(
                    backgroundColor: Color(0xFF1A2421),
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (pinStatus == PinFlowStatus.unlocked) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _activateIfNeeded();
                  });
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