import 'package:flutter/material.dart';
import 'package:dopamine_budget/core/crypto/data/sync_prefs.dart';
import 'package:dopamine_budget/features/auth/auth_module.dart';
import 'package:dopamine_budget/features/auth/presentation/pages/magic_link_email_screen.dart';

class OnboardingFlow extends StatefulWidget {
  final AuthModule authModule;
  final VoidCallback onComplete;
  final Widget Function(VoidCallback onDone) onNewUser;

  const OnboardingFlow({
    super.key,
    required this.authModule,
    required this.onComplete,
    required this.onNewUser,
  });

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int _page = 0;
  final _nameController = TextEditingController();
  bool _nameError = false;

  static const _bg = Color(0xFF1A2421);
  static const _accent = Color(0xFF8EB897);
  static const _textPrimary = Color(0xFFF2EFEA);
  static const _textSecondary = Color(0xFFA8B5AF);

  final _slides = const [
    _SlideData(
      icon: Icons.forest_outlined,
      title: 'Ваше личное убежище',
      subtitle: 'Место без осуждения,\nгде вы управляете своими привычками.',
    ),
    _SlideData(
      icon: Icons.water_drop_outlined,
      title: 'Режим усыхания',
      subtitle: 'Постепенное снижение дофаминовой нагрузки\nв комфортном для вас темпе.',
    ),
    _SlideData(
      icon: Icons.self_improvement_outlined,
      title: 'Конфиденциальность',
      subtitle: 'Ваши данные хранятся локально на устройстве.\nМы не видим ничего.',
    ),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _next() {
    // Страница имени — индекс _slides.length - 1 (перед синхронизацией)
    if (_page == _slides.length - 1) {
      if (_nameController.text.trim().isEmpty) {
        setState(() => _nameError = true);
        return;
      }
      SyncPrefs.setDisplayName(_nameController.text.trim());
    }
    setState(() {
      _nameError = false;
      _page++;
    });
  }

  void _openAuthFlow() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => MagicLinkEmailScreen(
          authNotifier: widget.authModule.authNotifier,
          onAuthComplete: () {
            // Сначала сбрасываем весь стек до корня, потом вызываем onComplete
            Navigator.of(context).popUntil((route) => route.isFirst);
            widget.onComplete();
          },
          onNewUser: widget.onNewUser,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: _buildPage(),
        ),
      ),
    );
  }

  Widget _buildPage() {
    // Слайды 0,1,2 — информационные
    if (_page < _slides.length - 1) {
      return _OnboardingPage(
        key: ValueKey('slide_$_page'),
        icon: _slides[_page].icon,
        title: _slides[_page].title,
        subtitle: _slides[_page].subtitle,
        isFirst: _page == 0,
        progress: (_page + 1) / (_slides.length + 1),
        onNext: _next,
        onSignIn: _page == 0 ? _openAuthFlow : null,
        onEnableSync: null,
      );
    }
    // Страница имени — индекс 3 (_slides.length - 1)
    if (_page == _slides.length - 1) {
      return _NameInputPage(
        key: const ValueKey('name_slide'),
        controller: _nameController,
        hasError: _nameError,
        progress: _slides.length / (_slides.length + 1),
        onNext: _next,
      );
    }
    // Слайд синхронизации — индекс 4 (_slides.length)
    if (_page == _slides.length) {
      return _OnboardingPage(
        key: const ValueKey('sync_slide'),
        icon: _slides.last.icon,
        title: _slides.last.title,
        subtitle: _slides.last.subtitle,
        isFirst: false,
        progress: 1.0,
        onNext: _next,
        onSignIn: null,
        onEnableSync: _openAuthFlow,
      );
    }
    // _page > _slides.length — завершение
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onComplete());
    return const SizedBox.shrink(key: ValueKey('done'));
  }
}

class _SlideData {
  final IconData icon;
  final String title;
  final String subtitle;
  const _SlideData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isFirst;
  final double progress;
  final VoidCallback onNext;
  final VoidCallback? onSignIn;
  final VoidCallback? onEnableSync;

  static const _textPrimary = Color(0xFFF2EFEA);
  static const _textSecondary = Color(0xFFA8B5AF);
  static const _accent = Color(0xFF8EB897);

  const _OnboardingPage({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isFirst,
    required this.progress,
    required this.onNext,
    this.onSignIn,
    this.onEnableSync,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _ProgressBar(progress: progress),
          const Spacer(flex: 2),
          _GlowIcon(icon: icon),
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 34,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 17,
              height: 1.5,
            ),
          ),
          const Spacer(flex: 3),
          if (onEnableSync != null) ...[
            _PrimaryButton(label: 'Включить синхронизацию', onTap: onEnableSync!),
            const SizedBox(height: 12),
            _SecondaryButton(label: 'Пропустить', onTap: onNext),
          ] else ...[
            _PrimaryButton(label: 'Далее', onTap: onNext),
            if (onSignIn != null) ...[
              const SizedBox(height: 12),
              _SecondaryButton(label: 'Войти в аккаунт', onTap: onSignIn!),
            ],
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _NameInputPage extends StatelessWidget {
  final TextEditingController controller;
  final bool hasError;
  final double progress;
  final VoidCallback onNext;

  static const _surface = Color(0xFF24342F);
  static const _textPrimary = Color(0xFFF2EFEA);
  static const _textSecondary = Color(0xFFA8B5AF);

  const _NameInputPage({
    super.key,
    required this.controller,
    required this.hasError,
    required this.progress,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
              const SizedBox(height: 24),
              _ProgressBar(progress: progress),
              const Spacer(flex: 2),
              const _GlowIcon(icon: Icons.person_outline),
              const SizedBox(height: 40),
              const Text(
                'Как к вам\nобращаться?',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: hasError
                        ? const Color(0xFFD3A26D)
                        : Colors.white.withOpacity(0.08),
                  ),
                ),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  style: const TextStyle(color: _textPrimary, fontSize: 17),
                  decoration: InputDecoration(
                    hintText: 'Ваше имя',
                    hintStyle: TextStyle(color: _textSecondary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),
                  onSubmitted: (_) => onNext(),
                ),
              ),
              if (hasError) ...[
                const SizedBox(height: 8),
                const Text(
                  'Введите имя, чтобы продолжить',
                  style: TextStyle(color: Color(0xFFD3A26D), fontSize: 14),
                ),
              ],
              const Spacer(flex: 3),
              _PrimaryButton(label: 'Продолжить', onTap: onNext),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  static const _surface = Color(0xFF24342F);
  static const _accent = Color(0xFF8EB897);

  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: _surface,
        valueColor: const AlwaysStoppedAnimation(_accent),
        minHeight: 3,
      ),
    );
  }
}

class _GlowIcon extends StatelessWidget {
  final IconData icon;
  static const _accent = Color(0xFF8EB897);

  const _GlowIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Icon(icon, color: _accent, size: 36),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  static const _accent = Color(0xFF8EB897);
  static const _bg = Color(0xFF1A2421);

  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 60,
        decoration: BoxDecoration(
          color: _accent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: _bg,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  static const _textSecondary = Color(0xFFA8B5AF);

  const _SecondaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}