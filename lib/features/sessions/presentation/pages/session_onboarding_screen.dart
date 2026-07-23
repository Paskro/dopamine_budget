import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/delete_session_use_case.dart';
import 'package:dopamine_budget/features/sessions/presentation/pages/profile_screen.dart';
import 'package:dopamine_budget/features/habits/presentation/state/habits_notifier.dart';
import 'package:dopamine_budget/features/habits/presentation/pages/habit_management_page.dart';

enum _OnboardingStep { intro, habitsSelection, limitInput }

class SessionOnboardingScreen extends StatefulWidget {
  final SessionRepository sessionRepository;
  final DeleteSessionUseCase deleteSessionUseCase;
  final Function(int days) onStartCalibration;
  final HabitsNotifier habitsNotifier;
  final Future<void> Function({
  required double limit,
  required Set<String> habitIds,
  }) onStartControlWithHabits;

  const SessionOnboardingScreen({
    super.key,
    required this.onStartCalibration,
    required this.onStartControlWithHabits,
    required this.sessionRepository,
    required this.deleteSessionUseCase,
    required this.habitsNotifier,
  });

  @override
  State<SessionOnboardingScreen> createState() => _SessionOnboardingScreenState();
}

class _SessionOnboardingScreenState extends State<SessionOnboardingScreen> {
  final _calibDaysController = TextEditingController(text: '7');
  final _limitController = TextEditingController(text: '100');

  _OnboardingStep _step = _OnboardingStep.intro;
  Set<String> _wizardSelectedHabitIds = {};
  bool _isStarting = false;

  @override
  void dispose() {
    _calibDaysController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  void _showCalibrationDialog() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => _CalibrationPickerScreen(
          initialDays: int.tryParse(_calibDaysController.text) ?? 7,
          onConfirm: (days) {
            _calibDaysController.text = days.toString();
            widget.onStartCalibration(days);
          },
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    switch (_step) {
      case _OnboardingStep.intro:
        return null;
      case _OnboardingStep.habitsSelection:
        return AppBar(
          title: const Text('Выберем привычки для контроля'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _step = _OnboardingStep.intro),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _step = _OnboardingStep.intro),
                      child: const Text('Назад'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _wizardSelectedHabitIds.isEmpty
                          ? null
                          : () => setState(() => _step = _OnboardingStep.limitInput),
                      child: const Text('Продолжить'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      case _OnboardingStep.limitInput:
        return AppBar(
          title: const Text('Дневной лимит'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _step = _OnboardingStep.habitsSelection),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _step = _OnboardingStep.intro),
                      child: const Text('Вернуться к выбору фазы'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isStarting
                          ? null
                          : () async {
                        final limit = double.tryParse(_limitController.text) ?? 100.0;
                        setState(() => _isStarting = true);
                        try {
                          await widget.onStartControlWithHabits(
                            limit: limit,
                            habitIds: _wizardSelectedHabitIds,
                          );
                        } finally {
                          if (mounted) setState(() => _isStarting = false);
                        }
                      },
                      child: _isStarting
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text('Начать'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }

  Widget _buildBody() {
    switch (_step) {
      case _OnboardingStep.intro:
        return Container(
          color: const Color(0xFF1A2421),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  const _HeroVessel(),
                  const SizedBox(height: 40),
                  const Text(
                    'Твой дофаминовый\nбюджет',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF2EFEA),
                      height: 1.25,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Выбери, как начать работу\nсо своими привычками и триггерами.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFA8B5AF),
                      height: 1.55,
                    ),
                  ),
                  const Spacer(flex: 2),
                  _OnboardingOptionCard(
                    isPrimary: true,
                    icon: Icons.bar_chart_rounded,
                    title: 'Начать калибровку',
                    description: 'Собираем статистику 7 дней — точный лимит',
                    onTap: _showCalibrationDialog,
                  ),
                  const SizedBox(height: 12),
                  _OnboardingOptionCard(
                    isPrimary: false,
                    icon: Icons.tune_rounded,
                    title: 'Установить лимит вручную',
                    description: 'Сразу перейти к контролю со своим значением',
                    onTap: () => setState(() {
                      _wizardSelectedHabitIds = {};
                      _step = _OnboardingStep.habitsSelection;
                    }),
                  ),
                  const Spacer(flex: 1),
                  const Text(
                    'Этот выбор можно изменить позже в профиле',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      color: Color(0xFF6E7A75),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      case _OnboardingStep.habitsSelection:
        return HabitManagementPage(
          habitsNotifier: widget.habitsNotifier,
          sessionId: '',
          embedded: true,
          localSelectedIds: _wizardSelectedHabitIds,
          onLocalSelectionChanged: (ids) =>
              setState(() => _wizardSelectedHabitIds = ids),
        );
      case _OnboardingStep.limitInput:
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Укажите ваш лимит на эту сессию. Если вы не знаете — начните с фазы калибровки.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _limitController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Дневной бюджет (XP)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }
}

// --- Вспомогательные виджеты (вне класса) ---

class _HeroVessel extends StatelessWidget {
  const _HeroVessel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: const Color(0xFF24342F),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: CustomPaint(painter: _VesselPainter()),
    );
  }
}

class _VesselPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const accent = Color(0xFF8EB897);

    final strokePaint = Paint()
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path1 = Path()
      ..moveTo(cx - 14, cy + 14)
      ..quadraticBezierTo(cx - 18, cy - 2, cx - 14, cy - 14)
      ..quadraticBezierTo(cx, cy - 20, cx + 14, cy - 14)
      ..quadraticBezierTo(cx + 18, cy - 2, cx + 14, cy + 14);
    canvas.drawPath(path1, strokePaint..color = accent.withOpacity(0.3));

    final path2 = Path()
      ..moveTo(cx - 10, cy + 14)
      ..quadraticBezierTo(cx - 13, cy, cx - 10, cy - 10)
      ..quadraticBezierTo(cx, cy - 15, cx + 10, cy - 10)
      ..quadraticBezierTo(cx + 13, cy, cx + 10, cy + 14);
    canvas.drawPath(path2, strokePaint..color = accent.withOpacity(0.6));

    final liquidPath = Path()
      ..moveTo(cx - 14, cy + 8)
      ..quadraticBezierTo(cx, cy + 4, cx + 14, cy + 8)
      ..lineTo(cx + 14, cy + 14)
      ..lineTo(cx - 14, cy + 14)
      ..close();
    canvas.drawPath(
      liquidPath,
      Paint()..color = accent.withOpacity(0.15)..style = PaintingStyle.fill,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 14, cy + 14, 28, 5),
        const Radius.circular(2),
      ),
      Paint()..color = accent.withOpacity(0.2),
    );

    canvas.drawLine(
      Offset(cx, cy - 26),
      Offset(cx, cy - 21),
      Paint()
        ..color = accent.withOpacity(0.5)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OnboardingOptionCard extends StatelessWidget {
  final bool isPrimary;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _OnboardingOptionCard({
    required this.isPrimary,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isPrimary ? const Color(0xFF8EB897) : const Color(0xFF24342F);
    final titleColor = isPrimary ? const Color(0xFF1A2421) : const Color(0xFFF2EFEA);
    final descColor = isPrimary
        ? const Color(0xFF1A2421).withOpacity(0.6)
        : const Color(0xFFA8B5AF);
    final iconBg = isPrimary
        ? const Color(0xFF1A2421).withOpacity(0.12)
        : Colors.white.withOpacity(0.04);
    final iconColor = isPrimary ? const Color(0xFF1A2421) : const Color(0xFF8EB897);
    final borderColor =
    isPrimary ? Colors.transparent : Colors.white.withOpacity(0.05);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      color: descColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: descColor, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Экран выбора дней калибровки
// ─────────────────────────────────────────────

class _CalibrationPickerScreen extends StatefulWidget {
  final int initialDays;
  final void Function(int days) onConfirm;

  const _CalibrationPickerScreen({
    required this.initialDays,
    required this.onConfirm,
  });

  @override
  State<_CalibrationPickerScreen> createState() =>
      _CalibrationPickerScreenState();
}

class _CalibrationPickerScreenState extends State<_CalibrationPickerScreen>
    with SingleTickerProviderStateMixin {
  static const _options = [
    (days: 3, title: '3 дня', desc: 'Быстрый старт. Подойдёт, если хочешь начать контроль уже на этой неделе.'),
    (days: 7, title: '7 дней — рекомендуем', desc: 'Полная картина недели. Средний балл будет точнее и честнее.'),
    (days: 14, title: '14 дней', desc: 'Максимальная точность. Учитывает циклы настроения и рабочую нагрузку.'),
  ];

  late int _selected;
  late AnimationController _holdController;

  // Цвет кнопки: зелёный → золотой по прогрессу hold
  static const _colorStart = Color(0xFF8EB897);
  static const _colorEnd   = Color(0xFFD3A26D);

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDays;
    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) _onHoldComplete();
    });
  }

  @override
  void dispose() {
    _holdController.dispose();
    super.dispose();
  }

  void _onHoldComplete() {
    HapticFeedback.heavyImpact();
    Navigator.of(context).pop();
    widget.onConfirm(_selected);
  }

  void _startHold() => _holdController.forward();

  void _cancelHold() {
    if (_holdController.status != AnimationStatus.completed) {
      _holdController.reverse();
    }
  }

  Color _lerpColor(double t) => Color.lerp(_colorStart, _colorEnd, t)!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2421),
      body: SafeArea(
        child: Column(
          children: [
            // ── Назад ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: const Icon(Icons.chevron_left,
                        color: Color(0xFFA8B5AF), size: 22),
                  ),
                ),
              ),
            ),

            // ── Hero ───────────────────────────────────
            const SizedBox(height: 28),
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF8EB897).withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: const Color(0xFF8EB897).withOpacity(0.14)),
              ),
              child: CustomPaint(painter: _CalibrationGridPainter()),
            ),
            const SizedBox(height: 20),
            const Text(
              'Сколько дней\nна калибровку?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF2EFEA),
                height: 1.25,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Это период наблюдения — без ограничений. Приложение изучит твой ритм.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 15,
                  color: Color(0xFFA8B5AF),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Карточки выбора ─────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    for (final opt in _options) ...[
                      _DayOptionCard(
                        days: opt.days,
                        title: opt.title,
                        desc: opt.desc,
                        selected: _selected == opt.days,
                        onTap: () => setState(() => _selected = opt.days),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // ── Tip ──────────────────────────────
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD3A26D).withOpacity(0.07),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color:
                            const Color(0xFFD3A26D).withOpacity(0.15)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color:
                              const Color(0xFFD3A26D).withOpacity(0.10),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.info_outline,
                                color: Color(0xFFD3A26D), size: 16),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Без осуждения. В эти дни ничего не ограничивается — живи как обычно. Данные нужны такими, какие они есть.',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 13,
                                color: Color(0xFFA8B5AF),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Hold-кнопка ─────────────────────────────
            Padding(
              padding:
              const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: AnimatedBuilder(
                animation: _holdController,
                builder: (_, __) {
                  final t = _holdController.value;
                  final fillColor = _lerpColor(t);
                  final labelColor =
                  t > 0.5 ? const Color(0xFF1A2421) : const Color(0xFF8EB897);

                  return GestureDetector(
                    onTapDown: (_) => _startHold(),
                    onTapUp: (_) => _cancelHold(),
                    onTapCancel: _cancelHold,
                    child: SizedBox(
                      height: 60,
                      child: Stack(
                        children: [
                          // фон + контур
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF24342F),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                  color: const Color(0xFF8EB897)
                                      .withOpacity(0.4)),
                            ),
                          ),
                          // заливка прогресса
                          FractionallySizedBox(
                            widthFactor: t,
                            child: Container(
                              decoration: BoxDecoration(
                                color: fillColor,
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                          ),
                          // лейбл
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Начать калибровку',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: labelColor,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded,
                                    color: labelColor, size: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Карточка выбора дней
// ─────────────────────────────────────────────

class _DayOptionCard extends StatelessWidget {
  final int days;
  final String title;
  final String desc;
  final bool selected;
  final VoidCallback onTap;

  const _DayOptionCard({
    required this.days,
    required this.title,
    required this.desc,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF2A3D37)
              : const Color(0xFF24342F),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF8EB897).withOpacity(0.35)
                : Colors.white.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF8EB897).withOpacity(0.12)
                    : Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  '$days',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? const Color(0xFF8EB897)
                        : const Color(0xFF6E7A75),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF2EFEA),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      color: Color(0xFFA8B5AF),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24, height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? const Color(0xFF8EB897)
                    : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? const Color(0xFF8EB897)
                      : Colors.white.withOpacity(0.12),
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check,
                  color: Color(0xFF1A2421), size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Иконка 2×2 сетки для hero
// ─────────────────────────────────────────────

class _CalibrationGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const accent = Color(0xFF8EB897);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    const r = Radius.circular(3);
    final rects = [
      Rect.fromLTWH(10, 10, 18, 18),
      Rect.fromLTWH(10, 34, 18, 18),
      Rect.fromLTWH(34, 10, 18, 18),
    ];
    for (final rect in rects) {
      canvas.drawRRect(RRect.fromRectAndRadius(rect, r),
          paint..color = accent);
    }
    // 4-й пунктирный
    final dashPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = accent.withOpacity(0.3);
    _drawDashedRect(
        canvas, RRect.fromRectAndRadius(Rect.fromLTWH(34, 34, 18, 18), r),
        dashPaint, 3, 3);
  }

  void _drawDashedRect(
      Canvas canvas, RRect rrect, Paint paint, double dash, double gap) {
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics().first;
    double dist = 0;
    while (dist < metrics.length) {
      canvas.drawPath(
          metrics.extractPath(dist, dist + dash), paint);
      dist += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}