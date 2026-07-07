import 'package:flutter/foundation.dart';
import 'package:dopamine_budget/core/utils/time_provider.dart';
import 'package:dopamine_budget/features/streak/domain/entities/streak_record.dart';
import 'package:dopamine_budget/features/streak/domain/repositories/i_streak_repository.dart';
import 'package:dopamine_budget/features/streak/domain/usecases/sync_streak_usecase.dart';
import 'streak_state.dart';

class StreakNotifier extends ChangeNotifier {
  final SyncStreakUseCase _syncStreakUseCase;
  final IStreakRepository _repository;

  StreakState _state = const StreakState(isLoading: true);
  StreakState get state => _state;

  StreakNotifier({
    required SyncStreakUseCase syncStreakUseCase,
    required IStreakRepository repository,
  })  : _syncStreakUseCase = syncStreakUseCase,
        _repository = repository;

  Future<void> init() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final record = await _syncStreakUseCase.execute();
    _state = StreakState(
      record: record,
      displayCase: record != null
          ? _resolveDisplayCase(record)
          : StreakDisplayCase.silence,
      isLoading: false,
    );
    notifyListeners();
  }

  Future<void> markViewed() async {
    await _repository.markViewed();
    if (_state.record == null) return;
    _state = _state.copyWith(
      record: _state.record!.copyWith(isViewed: true),
    );
    notifyListeners();
  }

  StreakDisplayCase _resolveDisplayCase(StreakRecord record) {
    if (record.isViewed) return StreakDisplayCase.silence;

    final prev = record.previousMultiplier;
    final curr = record.currentMultiplier;

    if (!record.hadActivityYesterday && prev == 1.0 && curr == 1.0) {
      return StreakDisplayCase.silence;
    }
    if (!record.hadActivityYesterday && curr == 1.0) return StreakDisplayCase.neutral;
    if (record.hadActivityYesterday && curr >= 1.2) return StreakDisplayCase.peak;
    if (record.hadActivityYesterday) return StreakDisplayCase.growth;
    return StreakDisplayCase.decay;
  }
}