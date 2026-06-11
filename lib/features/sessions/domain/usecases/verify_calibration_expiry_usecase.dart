import 'package:dopamine_budget/core/utils/time_provider.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/features/scoring/domain/repositories/scoring_repository.dart';

// lib/features/sessions/domain/usecases/verify_calibration_expiry_usecase.dart

/// Проверяет завершённость калибровки.
/// Если условия выполнены — самостоятельно переключает фазу в БД (side effect инкапсулирован).
/// Возвращает true если сессия уже в фазе контроля или перешла в неё прямо сейчас.
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

    // Уже в фазе контроля — ничего не делаем
    if (currentSession.phase == 1) return true;

    final uniqueDays = await _scoringRepository.getUniqueRecordedDays();
    final completedDays = uniqueDays.length;
    final targetDays = currentSession.calibrationDays;

    final today = DateTime(
      TimeProvider.now.year,
      TimeProvider.now.month,
      TimeProvider.now.day,
    );

    // Последний день калибровки должен быть вчера или раньше (не сегодня)
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

    // Калибровка истекла — считаем AVG и переключаем фазу
    double totalScore = 0;
    for (final day in uniqueDays.take(targetDays)) {
      totalScore += (await _scoringRepository.getScoreForDay(day)).toDouble();
    }
    final avgScore = totalScore / targetDays;

    final updatedSession = currentSession.copyWith(
      phase: 1,
      avgScore: avgScore,
    );

    // Side effect инкапсулирован здесь — нотификатор только читает результат
    await _sessionRepository.updateSession(updatedSession);

    print('🚀 [VerifyCalibrationExpiry] Калибровка завершена! avg=$avgScore');
    return true;
  }
}