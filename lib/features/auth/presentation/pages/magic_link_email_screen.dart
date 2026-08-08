import 'package:flutter/material.dart';
import '../state/auth_notifier.dart';
import '../state/auth_state.dart';

class MagicLinkEmailScreen extends StatefulWidget {
  final AuthNotifier authNotifier;
  final VoidCallback? onAuthComplete;
  final Widget Function(VoidCallback onDone)? onNewUser;

  const MagicLinkEmailScreen({
    super.key,
    required this.authNotifier,
    this.onAuthComplete,
    this.onNewUser,
  });

  @override
  State<MagicLinkEmailScreen> createState() => _MagicLinkEmailScreenState();
}

class _MagicLinkEmailScreenState extends State<MagicLinkEmailScreen> {
  final _emailController = TextEditingController();

  static const _bg = Color(0xFF1A2421);
  static const _surface = Color(0xFF24342F);
  static const _accent = Color(0xFF8EB897);
  static const _textPrimary = Color(0xFFF2EFEA);
  static const _textSecondary = Color(0xFFA8B5AF);
  static const _clay = Color(0xFFD3A26D);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) return;
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

        // После успешного auth — вызываем колбэк если он есть
        if (state.status == AuthStatus.existingUser ||
            state.status == AuthStatus.authenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (widget.onAuthComplete != null) {
              widget.onAuthComplete!();
            } else if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          });
        }

        if (state.status == AuthStatus.newUser &&
            widget.onNewUser != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) =>
                    widget.onNewUser!(widget.onAuthComplete ?? () {}),
                transitionsBuilder: (_, anim, __, child) =>
                    FadeTransition(opacity: anim, child: child),
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          });
        }

        return Scaffold(
          backgroundColor: _bg,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Navigator.canPop(context)
                ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: _textSecondary, size: 20),
              onPressed: () => Navigator.pop(context),
            )
                : null,
          ),
            body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                  const Spacer(flex: 2),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _accent.withOpacity(0.08),
                      boxShadow: [
                        BoxShadow(
                          color: _accent.withOpacity(0.15),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.lock_outline,
                        color: _accent, size: 36),
                  ),
                  const SizedBox(height: 40),
                  if (isAwaiting) ...[
                    const Text(
                      'Проверьте почту',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ссылка для входа отправлена на\n${_emailController.text.trim()}',
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 17,
                        height: 1.5,
                      ),
                    ),
                    const Spacer(flex: 3),
                    GestureDetector(
                      onTap: () =>
                          widget.authNotifier.sendMagicLink(_emailController.text.trim()),
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.08)),
                        ),
                        child: const Center(
                          child: Text(
                            'Отправить повторно',
                            style: TextStyle(
                                color: _textSecondary,
                                fontSize: 17,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'Войти в аккаунт',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Введите email — мы отправим\nссылку для входа.',
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 17,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: state.errorMessage != null
                              ? _clay
                              : Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofocus: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        style: const TextStyle(
                            color: _textPrimary, fontSize: 17),
                        decoration: InputDecoration(
                          hintText: 'your@email.com',
                          hintStyle:
                          const TextStyle(color: _textSecondary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                        ),
                      ),
                    ),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        state.errorMessage!,
                        style: const TextStyle(
                            color: _clay, fontSize: 14),
                      ),
                    ],
                    const Spacer(flex: 3),
                    GestureDetector(
                      onTap: isLoading ? null : _submit,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        height: 60,
                        decoration: BoxDecoration(
                          color: isLoading
                              ? _accent.withOpacity(0.45)
                              : _accent,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Center(
                          child: isLoading
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF1A2421),
                            ),
                          )
                              : const Text(
                            'Продолжить',
                            style: TextStyle(
                              color: Color(0xFF1A2421),
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: isLoading ? null : widget.authNotifier.signInWithGoogle,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        height: 60,
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.g_mobiledata, color: _textPrimary, size: 26),
                            const SizedBox(width: 12),
                            const Text(
                              'Войти через Google',
                              style: TextStyle(
                                color: _textPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
                      ),
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}