import 'package:flutter/material.dart';
import 'package:dopamine_budget/features/scoring/domain/entities/weekly_habits_report.dart';
import 'package:dopamine_budget/features/scoring/domain/usecases/get_weekly_habits_report_usecase.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';

class WeeklyDetailBottomSheet extends StatefulWidget {
  final Session session;
  final DateTime weekStart;
  final GetWeeklyHabitsReportUseCase getWeeklyHabitsReportUseCase;

  const WeeklyDetailBottomSheet({
    Key? key,
    required this.session,
    required this.weekStart,
    required this.getWeeklyHabitsReportUseCase,
  }) : super(key: key);

  @override
  State<WeeklyDetailBottomSheet> createState() => _WeeklyDetailBottomSheetState();
}

class _WeeklyDetailBottomSheetState extends State<WeeklyDetailBottomSheet> {
  late final Future<WeeklyHabitsReport> _reportFuture;
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _reportFuture = widget.getWeeklyHabitsReportUseCase.call(
      weekStart: widget.weekStart,
      session: widget.session,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: FutureBuilder<WeeklyHabitsReport>(
            future: _reportFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFEF9F27)));
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Ошибка загрузки: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white54),
                  ),
                );
              }
              final report = snapshot.data!;
              return _buildContent(scrollController, report);
            },
          ),
        );
      },
    );
  }

  Widget _buildContent(ScrollController scrollController, WeeklyHabitsReport report) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        _buildDragger(),
        _buildTitle(),
        const SizedBox(height: 20),
        if (report.slices.isEmpty)
          _buildEmpty()
        else ...[
          _buildChart(report),
          const SizedBox(height: 16),
          _buildSummaryBar(report),
          const SizedBox(height: 20),
          _buildDivider('Рейтинг привычек'),
          const SizedBox(height: 12),
          _buildRatingList(report),
          const SizedBox(height: 20),
          _buildInsight(report),
        ],
        const SizedBox(height: 20),
        _buildCloseButton(),
      ],
    );
  }

  Widget _buildDragger() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Column(
      children: [
        Text(
          'Распределение бюджета',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 4),
        Text(
          'Анализ расходов за неделю',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.white38),
        ),
      ],
    );
  }

  Widget _buildChart(WeeklyHabitsReport report) {
    final total = report.isOverBudget ? report.totalSpent : report.totalLimit;

    return SizedBox(
      height: 180,
      child: Row(
        children: [
          SizedBox(
            width: 160,
            height: 160,
            child: CustomPaint(
              painter: _DonutPainter(
                report: report,
                total: total,
                selectedIndex: _selectedIndex,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...report.slices.asMap().entries.map((e) => _buildLegendItem(e.key, e.value, total)),
                if (!report.isOverBudget && report.savedPts != null)
                  _buildLegendItem(-1, null, total, isSaved: true, savedPts: report.savedPts!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(int idx, HabitWeeklySlice? slice, int total, {
    bool isSaved = false,
    int? savedPts,
  }) {
    final color = isSaved ? const Color(0xFF1D9E75) : slice!.color;
    final label = isSaved ? 'Сэкономлено' : slice!.habitName;
    final pct = isSaved
        ? ((savedPts! / total) * 100).round()
        : ((slice!.totalPts / total) * 100).round();
    final isActive = _selectedIndex == idx;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = isActive ? -1 : idx),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.07) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.white70),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '$pct%',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBar(WeeklyHabitsReport report) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Всего израсходовано', style: TextStyle(fontSize: 12, color: Colors.white54)),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13),
              children: [
                TextSpan(
                  text: '${report.totalSpent} pts',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                ),
                TextSpan(
                  text: ' из ${report.totalLimit}',
                  style: const TextStyle(color: Colors.white38),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(String label) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 10, color: Colors.white38, letterSpacing: 0.8),
        ),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 0.5, color: Colors.white12)),
      ],
    );
  }

  Widget _buildRatingList(WeeklyHabitsReport report) {
    final items = <Widget>[];

    for (int i = 0; i < report.slices.length; i++) {
      final slice = report.slices[i];
      final isHighlighted = _selectedIndex == i;
      items.add(_buildHabitRow(i, slice, isHighlighted));
    }

    if (!report.isOverBudget && report.savedPts != null) {
      items.add(_buildSavingsRow(report.savedPts!));
    }

    return Column(children: items);
  }

  Widget _buildHabitRow(int idx, HabitWeeklySlice slice, bool isHighlighted) {
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = isHighlighted ? -1 : idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(
          horizontal: isHighlighted ? 0 : 0,
          vertical: 2,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isHighlighted ? 10 : 0,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isHighlighted ? Colors.white.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border(
            bottom: BorderSide(
              color: isHighlighted ? Colors.transparent : Colors.white.withOpacity(0.07),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: slice.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  '${idx + 1}.',
                  style: const TextStyle(fontSize: 11, color: Colors.white38),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    slice.habitName,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 18),
              child: Row(
                children: [
                  _StatChip(label: 'За неделю', value: '${slice.totalPts} pts'),
                  const SizedBox(width: 12),
                  _StatChip(label: 'Доля', value: '${slice.percentage.round()}%'),
                  const SizedBox(width: 12),
                  _StatChip(label: 'В среднем/день', value: '${slice.avgPerDay} pts'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 18),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: slice.percentage / 100,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(slice.color),
                  minHeight: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsRow(int savedPts) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: Color(0xFF1D9E75), shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              'Сэкономлено',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1D9E75).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$savedPts pts сохранено',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1D9E75)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsight(WeeklyHabitsReport report) {
    if (report.slices.isEmpty) return const SizedBox.shrink();
    final top = report.slices.first;
    final saving = (top.totalPts * 0.1).round();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: const Color(0xFF7F77DD), width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ТЕРАПЕВТИЧЕСКИЙ ИНСАЙТ',
            style: TextStyle(fontSize: 10, color: Color(0xFF7F77DD), letterSpacing: 0.8, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: Colors.white54, height: 1.6),
              children: [
                const TextSpan(text: 'Ваш главный «абсорбер» на этой неделе — '),
                TextSpan(
                  text: top.habitName,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
                TextSpan(text: ': ${top.percentage.round()}% бюджета. Сократив её на 10%, вы высвободите '),
                TextSpan(
                  text: '$saving pts',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
                const TextSpan(text: ' для более экологичного отдыха.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(Icons.bar_chart_rounded, size: 48, color: Colors.white24),
          SizedBox(height: 16),
          Text(
            'За эту неделю записей нет',
            style: TextStyle(fontSize: 15, color: Colors.white38),
          ),
          SizedBox(height: 8),
          Text(
            'Привычки появятся здесь после первых кликов',
            style: TextStyle(fontSize: 12, color: Colors.white24),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white70,
        side: BorderSide(color: Colors.white.withOpacity(0.15)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () => Navigator.of(context).pop(),
      child: const Text('Понятно'),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white38)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white)),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final WeeklyHabitsReport report;
  final int total;
  final int selectedIndex;

  _DonutPainter({
    required this.report,
    required this.total,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 28.0;
    const gapAngle = 0.03;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -1.5708;

    final slices = <({Color color, double sweep})>[];

    for (final slice in report.slices) {
      slices.add((
      color: slice.color,
      sweep: (slice.totalPts / total) * 2 * 3.14159 - gapAngle,
      ));
    }

    if (!report.isOverBudget && report.savedPts != null) {
      slices.add((
      color: const Color(0xFF1D9E75),
      sweep: (report.savedPts! / total) * 2 * 3.14159 - gapAngle,
      ));
    }

    for (int i = 0; i < slices.length; i++) {
      final s = slices[i];
      final isSelected = selectedIndex == i;
      final effectiveRadius = isSelected ? radius + 6 : radius;

      paint.color = selectedIndex == -1 || isSelected
          ? s.color
          : s.color.withOpacity(0.25);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: effectiveRadius),
        startAngle,
        s.sweep,
        false,
        paint,
      );
      startAngle += s.sweep + gapAngle;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.selectedIndex != selectedIndex || old.report != report;
}