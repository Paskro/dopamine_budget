import 'package:dopamine_budget/features/streak/domain/entities/streak_record.dart';

enum StreakDisplayCase { growth, peak, decay, neutral, silence }

class StreakState {
  final StreakRecord? record;
  final StreakDisplayCase displayCase;
  final bool isLoading;

  const StreakState({
    this.record,
    this.displayCase = StreakDisplayCase.silence,
    this.isLoading = false,
  });

  StreakState copyWith({
    StreakRecord? record,
    StreakDisplayCase? displayCase,
    bool? isLoading,
  }) => StreakState(
    record: record ?? this.record,
    displayCase: displayCase ?? this.displayCase,
    isLoading: isLoading ?? this.isLoading,
  );
}