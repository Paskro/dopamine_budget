import 'package:dopamine_budget/features/streak/domain/entities/streak_record.dart';

abstract interface class IStreakRepository {
  Future<StreakRecord?> getStreak();
  Future<void> syncStreak();
  Future<void> markViewed();
}