import 'package:flutter/material.dart';
import 'package:dopamine_budget/features/scoring/domain/entities/weekly_habits_report.dart';
import 'package:dopamine_budget/features/scoring/domain/repositories/scoring_repository.dart';
import 'package:dopamine_budget/features/sessions/domain/entities/session.dart';

const _palette = [
  Color(0xFF7F77DD),
  Color(0xFF888780),
  Color(0xFFBA7517),
  Color(0xFF1D9E75),
  Color(0xFFD85A30),
  Color(0xFF378ADD),
  Color(0xFF639922),
  Color(0xFFD4537E),
];

class GetWeeklyHabitsReportUseCase {
  final ScoringRepository _repo;

  const GetWeeklyHabitsReportUseCase(this._repo);

  Future<WeeklyHabitsReport> call({
    required DateTime weekStart,
    required Session session,
  }) async {
    final baseLimit = session.baseShrinkingLimit ?? session.avgScore;
    if (baseLimit == null) throw StateError('Session not in control phase');
    final totalLimit = (baseLimit * 7).round();
    final rows = await _repo.getWeeklyHabitTotals(weekStart: weekStart);

    final totalSpent = rows.fold<int>(0, (sum, r) => sum + r.totalPts);

    final base = totalSpent > 0 ? totalSpent : 1;

    final slices = rows.asMap().entries.map((entry) {
      final i = entry.key;
      final r = entry.value;
      return HabitWeeklySlice(
        habitId: r.habitId,
        habitName: r.habitName,
        color: _palette[i % _palette.length],
        totalPts: r.totalPts,
        percentage: (r.totalPts / base * 100),
        avgPerDay: (r.totalPts / 7).round(),
      );
    }).toList()
      ..sort((a, b) => b.totalPts.compareTo(a.totalPts));

    final savedPts = totalSpent < totalLimit ? totalLimit - totalSpent : null;

    return WeeklyHabitsReport(
      slices: slices,
      totalSpent: totalSpent,
      totalLimit: totalLimit,
      savedPts: savedPts,
    );
  }
}