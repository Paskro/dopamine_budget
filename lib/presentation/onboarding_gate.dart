import 'package:flutter/material.dart';
import 'package:dopamine_budget/core/crypto/data/sync_prefs.dart';
import 'package:dopamine_budget/features/auth/auth_module.dart';
import 'package:dopamine_budget/features/onboarding/presentation/pages/onboarding_flow.dart';

class OnboardingGate extends StatefulWidget {
  final Widget child;
  final AuthModule authModule;
  final Widget Function(VoidCallback onDone) onNewUser;

  const OnboardingGate({
    super.key,
    required this.child,
    required this.authModule,
    required this.onNewUser,
  });

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  bool? _done;

  @override
  void initState() {
    super.initState();
    SyncPrefs.isOnboardingDone().then((v) {
      if (mounted) setState(() => _done = v);
    });
  }

  void _onOnboardingComplete() {
    SyncPrefs.setOnboardingDone().then((_) {
      if (mounted) setState(() => _done = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_done == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A2421),
        body: SizedBox.shrink(),
      );
    }
    if (_done == true) return widget.child;
    return OnboardingFlow(
      authModule: widget.authModule,
      onComplete: _onOnboardingComplete,
      onNewUser: widget.onNewUser,
    );
  }
}