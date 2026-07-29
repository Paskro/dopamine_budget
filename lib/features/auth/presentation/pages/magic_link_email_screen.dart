import 'package:flutter/material.dart';
import '../state/auth_notifier.dart';
import '../state/auth_state.dart';

class MagicLinkEmailScreen extends StatefulWidget {
  final AuthNotifier authNotifier;

  const MagicLinkEmailScreen({super.key, required this.authNotifier});

  @override
  State<MagicLinkEmailScreen> createState() => _MagicLinkEmailScreenState();
}

class _MagicLinkEmailScreenState extends State<MagicLinkEmailScreen> {
  final _emailController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) return;
    setState(() => _submitted = true);
    await widget.authNotifier.sendMagicLink(email);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.authNotifier,
      builder: (context, _) {
        final state = widget.authNotifier.state;
        final isLoading = state.status == AuthStatus.loading;
        final isAwaiting = state.status == AuthStatus.awaitingMagicLink;

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Dopamine\nBudget',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 48),
                  if (isAwaiting) ...[
                    const Icon(Icons.mark_email_read_outlined, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Проверьте почту\n\nМы отправили ссылку на\n${_emailController.text.trim()}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => setState(() => _submitted = false),
                      child: const Text('Отправить другой адрес'),
                    ),
                  ] else ...[
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'your@email.com',
                      ),
                    ),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        state.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text('Войти / Зарегистрироваться'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}