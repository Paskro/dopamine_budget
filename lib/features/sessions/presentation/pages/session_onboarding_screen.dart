import 'package:flutter/material.dart';
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
  required Set<int> habitIds,
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
  Set<int> _wizardSelectedHabitIds = {};
  bool _isStarting = false;

  @override
  void dispose() {
    _calibDaysController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  void _showCalibrationDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Период калибровки'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Сколько дней вы хотите собирать статистику срывов?'),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () =>
                        setDialogState(() => _calibDaysController.text = '3'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: const Text('3 дня'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () =>
                        setDialogState(() => _calibDaysController.text = '7'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: const Text('7 дней (Реком.)'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _calibDaysController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Свой вариант (дней)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                final days = int.tryParse(_calibDaysController.text) ?? 7;
                Navigator.pop(context);
                widget.onStartCalibration(days);
              },
              child: const Text('Запустить'),
            ),
          ],
        ),
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