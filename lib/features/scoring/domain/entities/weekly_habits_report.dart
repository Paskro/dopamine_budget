import 'package:flutter/material.dart';

class HabitWeeklySlice {
  final int habitId;
  final String habitName;
  final Color color;
  final int totalPts;
  final double percentage;
  final int avgPerDay;

  const HabitWeeklySlice({
    required this.habitId,
    required this.habitName,
    required this.color,
    required this.totalPts,
    required this.percentage,
    required this.avgPerDay,
  });
}

class WeeklyHabitsReport {
  final List<HabitWeeklySlice> slices;
  final int totalSpent;
  final int totalLimit;
  final int? savedPts;

  const WeeklyHabitsReport({
    required this.slices,
    required this.totalSpent,
    required this.totalLimit,
    required this.savedPts,
  });

  bool get isOverBudget => totalSpent >= totalLimit;
}