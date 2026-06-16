import 'package:dopamine_budget/core/utils/time_provider.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/features/scoring/domain/repositories/scoring_repository.dart';

// lib/features/sessions/domain/usecases/verify_calibration_expiry_usecase.dart

class VerifyCalibrationExpiryUseCase {
  final SessionRepository _sessionRepository;
  final ScoringRepository _scoringRepository;

  VerifyCalibrationExpiryUseCase({
    required SessionRepository sessionRepository,
    required ScoringRepository scoringRepository,
  })  : _sessionRepository = sessionRepository,
        _scoringRepository = scoringRepository;

  Future<bool> execute() async {
    final currentSession = await _sessionRepository.getActiveSession();
    if (currentSession == null) return false;

    if (currentSession.phase == 1) return true;

    if (currentSession.phase == 1) {
      print('VCE: уже phase=1, выходим без пересчёта');
      return true;
    }
    print('VCE: phase=${currentSession.phase}, ИДЁМ ДАЛЬШЕ — это бы не должно происходить если контроль уже активен');

    final uniqueDays = await _scoringRepository.getUniqueRecordedDays();
    final completedDays = uniqueDays.length;
    final targetDays = currentSession.calibrationDays;

    final today = DateTime(
      TimeProvider.now.year,
      TimeProvider.now.month,
      TimeProvider.now.day,
    );

    final lastCalibrationDay = uniqueDays.isNotEmpty
        ? DateTime(
            uniqueDays.last.year,
            uniqueDays.last.month,
            uniqueDays.last.day,
          )
        : null;
    final lastDayIsComplete =
        lastCalibrationDay != null && lastCalibrationDay.isBefore(today);

    if (completedDays < targetDays || !lastDayIsComplete) return false;

    double totalScore = 0;
    for (final day in uniqueDays.take(targetDays)) {
      totalScore += (await _scoringRepository.getScoreForDay(day)).toDouble();
    }
    final avgScore = totalScore / targetDays;

    // Фиксируем точный момент перехода в контроль — будет использован
    // как нижняя граница для watchScoreForDay в ControlScreenNotifier,
    // чтобы калибровочные клики не попадали в баланс контроля.
    final updatedSession = currentSession.copyWith(
      phase: 1,
      avgScore: avgScore,
      controlStartedAt: TimeProvider.now,
    );

    await _sessionRepository.updateSession(updatedSession);

    print('🚀 [VerifyCalibrationExpiry] Калибровка завершена! avg=$avgScore, controlStartedAt=${updatedSession.controlStartedAt}');
    return true;
  }
}