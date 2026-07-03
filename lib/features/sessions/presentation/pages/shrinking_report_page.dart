import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dopamine_budget/features/sessions/domain/usecases/check_and_generate_shrinking_report_usecase.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/core/notifications/notification_scheduler.dart';
import 'package:dopamine_budget/core/notifications/notification_prefs.dart';

class ShrinkingReportPage extends StatelessWidget {
  final ShrinkingReportData reportData;
  final SessionRepository sessionRepository;
  final VoidCallback onContinue;

  const ShrinkingReportPage({
    super.key,
    required this.reportData,
    required this.sessionRepository,
    required this.onContinue,
  });

  String _fmt(DateTime d) => DateFormat('dd.MM.yyyy').format(d);

  Future<void> _onGoodTap(BuildContext context) async {
    await sessionRepository.markShrinkingReportReviewed(
      reportData.activePeriod.sessionId,
      reportData.weekStart,
    );
    await NotificationScheduler.cancelShrinkPush();
    final notifyTime = await NotificationPrefs.getShrinkNotifyTime();
    final nextReportDay = reportData.weekEnd.add(
      Duration(days: reportData.activePeriod.intervalDays + 1),
    );
    await NotificationScheduler.scheduleNextShrinkPush(
      reportDay: nextReportDay,
      notifyTime: notifyTime,
    );
    onContinue();
  }

  @override
  Widget build(BuildContext context) {
    final period = '${_fmt(reportData.weekStart)} — ${_fmt(reportData.weekEnd)}';
    final delta = reportData.thisAvgRemaining != null && reportData.prevAvgRemaining != null
        ? reportData.thisAvgRemaining! - reportData.prevAvgRemaining!
        : null;
    final showBreakdownWarning = reportData.sessionMode == 'basic' &&
        reportData.thisBrokenDays != null &&
        reportData.prevBrokenDays != null &&
        reportData.thisBrokenDays! > reportData.prevBrokenDays!;
    final showNegativeWarning = reportData.sessionMode == 'no_negative' &&
        delta != null &&
        delta < -(reportData.currentLimit * 0.05);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(period),
              const SizedBox(height: 24),
              _buildProgressBlock(),
              const SizedBox(height: 16),
              _buildDynamicsBlock(delta),
              if (showBreakdownWarning || showNegativeWarning) ...[
                const SizedBox(height: 16),
                _buildWarningBlock(),
              ],
              const SizedBox(height: 16),
              _buildNextWeekBlock(),
              if (reportData.isEditAllowed) ...[
                const SizedBox(height: 12),
                _buildEditHint(),
              ],
              const SizedBox(height: 32),
              _buildContinueButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String period) {
    return Column(
      children: [
        const Icon(Icons.trending_down_rounded, size: 56, color: Color(0xFFEF9F27)),
        const SizedBox(height: 16),
        Text(
          'Итоги периода усыхания №${reportData.periodIndex}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(period,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.white38)),
      ],
    );
  }

  Widget _buildProgressBlock() {
    return _SectionCard(
      label: 'Прогресс',
      child: Column(
        children: [
          _MetricRow(
            label: 'Стартовые баллы (калибровка)',
            value: '${reportData.baseLimit.round()} pts',
          ),
          const SizedBox(height: 10),
          _MetricRow(
            label: 'Усыханий прошло',
            value: '${reportData.shrinkCount}',
          ),
          const SizedBox(height: 10),
          _MetricRow(
            label: 'Текущий лимит',
            value: '${reportData.currentLimit.round()} pts',
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicsBlock(double? delta) {
    String deltaText = '—';
    Color deltaColor = Colors.white70;

    if (delta != null) {
      final sign = delta >= 0 ? '+' : '';
      deltaText = '$sign${delta.round()} pts ${delta >= 0 ? '📈' : '📉'}';
      deltaColor = delta >= 0 ? const Color(0xFF63991E) : const Color(0xFFE24B4A);
    }

    return _SectionCard(
      label: 'Динамика периода',
      child: Column(
        children: [
          _MetricRow(
            label: 'Средний остаток (пред. период)',
            value: reportData.prevAvgRemaining != null
                ? '${reportData.prevAvgRemaining!.round()} pts'
                : '—',
          ),
          const SizedBox(height: 10),
          if (reportData.sessionMode == 'basic' && reportData.prevBrokenDays != null)
            _MetricRow(
              label: 'Дней срывов (пред. период)',
              value: '${reportData.prevBrokenDays}',
            ),
          if (reportData.sessionMode == 'basic' && reportData.prevBrokenDays != null)
            const SizedBox(height: 10),
          _MetricRow(
            label: 'Средний остаток (этот период)',
            value: reportData.thisAvgRemaining != null
                ? '${reportData.thisAvgRemaining!.round()} pts'
                : '—',
          ),
          const SizedBox(height: 10),
          if (reportData.sessionMode == 'basic' && reportData.thisBrokenDays != null)
            _MetricRow(
              label: 'Дней срывов (этот период)',
              value: '${reportData.thisBrokenDays}',
            ),
          if (reportData.sessionMode == 'basic' && reportData.thisBrokenDays != null)
            const SizedBox(height: 10),
          _MetricRow(
            label: 'Изменение остатка',
            value: deltaText,
            valueColor: deltaColor,
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBlock() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE24B4A).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE24B4A).withOpacity(0.4)),
      ),
      child: const Text(
        'Рекомендуем остановить режим усыхания и адаптироваться к текущим значениям.',
        style: TextStyle(fontSize: 13, color: Color(0xFFE24B4A)),
      ),
    );
  }

  Widget _buildNextWeekBlock() {
    return _SectionCard(
      label: 'Следующий период',
      child: _MetricRow(
        label: 'Лимит',
        value: '${reportData.nextLimit.round()} pts',
      ),
    );
  }

  Widget _buildEditHint() {
    return Text(
      'Сегодня ты можешь изменить настройки усыхания в разделе Настройки сессии.',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4)),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEF9F27),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      onPressed: () => _onGoodTap(context),
      child: const Text('Хорошо', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
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
          Text(label.toUpperCase(),
              style: const TextStyle(fontSize: 10, color: Colors.white38, letterSpacing: 0.8)),
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

  const _MetricRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.white54)),
        ),
        Text(value,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: valueColor ?? Colors.white)),
      ],
    );
  }
}