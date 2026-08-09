import 'package:dopamine_budget/features/habits/domain/entities/habit.dart';
import 'package:dopamine_budget/core/utils/time_provider.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/core/fcm/fcm_service.dart';

class AddActionUseCase {
  final SessionRepository _sessionRepository;
  final FcmService? _fcmService;

  AddActionUseCase(this._sessionRepository, {FcmService? fcmService})
      : _fcmService = fcmService;

  Future<void> execute(Habit habit) async {
    await _sessionRepository.logHabitClickWithStatusCheck(
      habitId: habit.id,
      scoreCost: habit.scoreValue,
      timestamp: TimeProvider.now,
    );
    _fcmService?.notifyOtherDevices().catchError((_) {});
  }
}
