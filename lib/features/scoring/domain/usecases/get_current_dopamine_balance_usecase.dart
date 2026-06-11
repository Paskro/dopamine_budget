import 'package:dopamine_budget/core/utils/time_provider.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/features/scoring/domain/repositories/scoring_repository.dart';

// lib/features/scoring/domain/usecases/get_current_dopamine_balance_usecase.dart

/// Возвращает текущий остаток баланса дофамина для экрана контроля.
/// Если isBrokenClicked == true — возвращает 0 без обращения к ActionsTable.
class GetCurrentDopamineBalanceUseCase {
  final SessionRepository _sessionRepository;
  final ScoringRepository _scoringRepository;

  GetCurrentDopamineBalanceUseCase({
    required SessionRepository sessionRepository,
    required ScoringRepository scoringRepository,
  })  : _sessionRepository = sessionRepository,
        _scoringRepository = scoringRepository;

  Future<int> execute() async {
    final today = DateTime(
      TimeProvider.now.year,
      TimeProvider.now.month,
      TimeProvider.now.day,
    );

    final dayLog = await _sessionRepository.getDayLog(today);
    if (dayLog != null && dayLog.isBrokenClicked) {
      print('[DopamineBalance] День сорван → баланс = 0');
      return 0;
    }

    final session = await _sessionRepository.getActiveSession();
    if (session == null) return 0;

    final dailyLimit = (session.dailyLimit ?? 0).toInt();
    final spent = await _scoringRepository.getScoreForDay(TimeProvider.now);
    final balance = (dailyLimit - spent).clamp(0, dailyLimit);

    print('[DopamineBalance] Лимит=$dailyLimit, потрачено=$spent, остаток=$balance');
    return balance;
  }
}