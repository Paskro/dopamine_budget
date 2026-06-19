import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/day_log.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/check_and_generate_weekly_report_usecase.dart';
import 'package:dopamine_budget/features/scoring/domain/entities/weekly_habits_report.dart';
import 'package:dopamine_budget/features/scoring/domain/usecases/get_weekly_habits_report_usecase.dart';
import 'package:dopamine_budget/features/scoring/presentation/pages/weekly_detail_bottom_sheet.dart';
import 'package:dopamine_budget/features/scoring/domain/usecases/get_weekly_habits_report_usecase.dart';
import 'package:dopamine_budget/features/scoring/presentation/pages/weekly_detail_bottom_sheet.dart';

class WeeklyReportPage extends StatelessWidget {
  final WeeklyReportData reportData;
  final VoidCallback onContinue;
  final GetWeeklyHabitsReportUseCase getWeeklyHabitsReportUseCase;

  const WeeklyReportPage({
    Key? key,
    required this.reportData,
    required this.onContinue,
    required this.getWeeklyHabitsReportUseCase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final period =
        '${_fmt(reportData.weekStart)} — ${_fmt(reportData.weekEnd)}';
    final deviation = reportData.deviationPercent;
    final isWeekly = reportData.session.decreaseInterval == 'week';
    final dailyLimit = reportData.session.dailyLimit?.round() ?? 0;
    final newLimit = isWeekly && reportData.session.decreasePercentage != null
        ? (dailyLimit -
        (dailyLimit * reportData.session.decreasePercentage! / 100))
        .round()
        : null;
    final weekStartNormalized = DateTime(
      reportData.weekStart.year,
      reportData.weekStart.month,
      reportData.weekStart.day,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(period),
              const SizedBox(height: 24),
              _buildDayMatrix(),
              const SizedBox(height: 20),
              _buildMetrics(deviation),
              const SizedBox(height: 20),
              _buildDetailButton(context, weekStartNormalized),
              const SizedBox(height: 20),
              _buildBudgetBlock(isWeekly, dailyLimit, newLimit),
              const SizedBox(height: 32),
              _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String period) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.celebration_rounded, size: 56, color: Color(0xFFEF9F27)),
        const SizedBox(height: 16),
        Text(
          'Неделя контроля ${reportData.weekNumber}',
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(
          period,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: Colors.white38),
        ),
      ],
    );
  }

  Widget _buildDayMatrix() {
    return _SectionCard(
      label: 'Статусы дней',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellWidth = constraints.maxWidth / 7;
          return Row(
            children: List.generate(7, (i) {
              final day = reportData.weekStart.add(Duration(days: i));
              final log = reportData.slots[i];
              return SizedBox(
                width: cellWidth,
                child: _DayCell(date: day, log: log),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildMetrics(double? deviation) {
    String deviationText = '—';
    Color deviationColor = Colors.white70;

    if (deviation != null) {
      final sign = deviation <= 0 ? '' : '+';
      deviationText =
      '$sign${deviation.round()}%  ${deviation <= 0 ? '📉' : '📈'}';
      deviationColor =
      deviation <= 0 ? const Color(0xFF63991E) : const Color(0xFFE24B4A);
    }

    return _SectionCard(
      label: 'Метрики осознанности',
      child: Column(
        children: [
          _MetricRow(
            label: 'Средний балл (валидные дни)',
            value: '${reportData.avgScore.round()} pts',
          ),
          const SizedBox(height: 10),
          _MetricRow(
            label: 'Отклонение от бюджета',
            value: deviationText,
            valueColor: deviationColor,
          ),
          const SizedBox(height: 10),
          _MetricRow(
            label: 'Уровень честности',
            value: '${reportData.honestDaysCount} из 7 дней',
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetBlock(bool isWeekly, int dailyLimit, int? newLimit) {
    return _SectionCard(
      label: 'Корректировка бюджета',
      child: isWeekly
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Плановое снижение',
                  style:
                  TextStyle(fontSize: 13, color: Colors.white54)),
              Text(
                newLimit != null
                    ? '$dailyLimit pts → $newLimit pts'
                    : '$dailyLimit pts',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: Colors.white.withOpacity(0.15)),
                    padding:
                    const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: null,
                  child: const Text('Изменить шаг',
                      style: TextStyle(
                          fontSize: 12, color: Colors.white38)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: Colors.white.withOpacity(0.15)),
                    padding:
                    const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: null,
                  child: const Text('Оставить',
                      style: TextStyle(
                          fontSize: 12, color: Colors.white38)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Гибкое управление темпом — следующий спринт',
            style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.25)),
          ),
        ],
      )
          : _buildMonthlyInfo(dailyLimit),
    );
  }

  Widget _buildMonthlyInfo(int dailyLimit) {
    final controlStart = reportData.session.controlStartedAt!;
    final now = reportData.weekEnd;
    final daysElapsed = now.difference(controlStart).inDays;
    final weeksElapsed = (daysElapsed / 7).round();
    final weeksLeft = (4 - weeksElapsed).clamp(0, 4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Текущий лимит: $dailyLimit pts',
          style: const TextStyle(fontSize: 13, color: Colors.white70),
        ),
        const SizedBox(height: 6),
        Text(
          'До следующей корректировки: $weeksLeft нед.',
          style: const TextStyle(fontSize: 13, color: Colors.white38),
        ),
      ],
    );
  }

  Widget _buildDetailButton(BuildContext context, DateTime weekStart) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFEF9F27),
        side: BorderSide(color: const Color(0xFFEF9F27).withOpacity(0.4)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: const Icon(Icons.bar_chart_rounded, size: 18),
      label: const Text('Подробнее по привычкам'),
      onPressed: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => WeeklyDetailBottomSheet(
          session: reportData.session,
          weekStart: weekStart,
          getWeeklyHabitsReportUseCase: getWeeklyHabitsReportUseCase,
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEF9F27),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      onPressed: onContinue,
      child: const Text(
        'Продолжить контроль',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _fmt(DateTime d) => DateFormat('dd.MM.yyyy').format(d);
}

class _DayCell extends StatelessWidget {
  final DateTime date;
  final DayLog? log;

  const _DayCell({required this.date, required this.log});

  @override
  Widget build(BuildContext context) {
    final dayName = DateFormat.E('ru').format(date);
    final icon = _icon();
    final color = _color();

    return Column(
      children: [
        Text(
          dayName,
          style: const TextStyle(fontSize: 10, color: Colors.white38),
        ),
        const SizedBox(height: 5),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.13),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.45), width: 1.2),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ],
    );
  }

  IconData _icon() {
    if (log == null) return Icons.remove_rounded;
    if (log!.isBrokenClicked) return Icons.heart_broken_rounded;
    return switch (log!.dayStatus) {
      'ideal' => Icons.star_rounded,
      'almost_ideal' => Icons.check_rounded,
      _ => Icons.check_rounded,
    };
  }

  Color _color() {
    if (log == null) return Colors.white24;
    if (log!.isBrokenClicked) return const Color(0xFFE24B4A);
    return switch (log!.dayStatus) {
      'ideal' => const Color(0xFFFFD700),
      'almost_ideal' => const Color(0xFFBA7517),
      _ => const Color(0xFF63991E),
    };
  }
}

class _SectionCard extends StatelessWidget {
  final String label;
  final Widget child;

  const _SectionCard({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
                fontSize: 10,
                color: Colors.white38,
                letterSpacing: 0.8),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _MetricRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
            const TextStyle(fontSize: 13, color: Colors.white54)),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.white)),
      ],
    );
  }
}