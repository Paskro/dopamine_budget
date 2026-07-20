import 'package:dopamine_budget/core/utils/time_provider.dart';
import 'package:dopamine_budget/features/sessions/domain/repositories/session_repository.dart';
import 'package:dopamine_budget/features/scoring/domain/repositories/scoring_repository.dart';
import 'package:dopamine_budget/features/scoring/domain/usecases/get_daily_limit_usecase.dart';

class GetCurrentDopamineBalanceUseCase {
  final SessionRepository _sessionRepository;
  final ScoringRepository _scoringRepository;
  final GetDailyLimitUseCase _getDailyLimitUseCase;

  GetCurrentDopamineBalanceUseCase({
    required SessionRepository sessionRepository,
    required ScoringRepository scoringRepository,
    required GetDailyLimitUseCase getDailyLimitUseCase,
  })  : _sessionRepository = sessionRepository,
        _scoringRepository = scoringRepository,
        _getDailyLimitUseCase = getDailyLimitUseCase;

  Future<int> execute() async {
    final today = DateTime(
      TimeProvider.now.year,
      TimeProvider.now.month,
      TimeProvider.now.day,
    );

    final dayLog = await _sessionRepository.getDayLog(today);
    if (dayLog != null && dayLog.dayStatus == 'broken') {
      print('[DopamineBalance] День сорван → баланс = 0');
      return 0;
    }

    final dailyLimitRaw = await _getDailyLimitUseCase.execute();
    if (dailyLimitRaw == null) return 0;

    final dailyLimit = dailyLimitRaw.round();
    final spent = await _scoringRepository.getScoreForDay(TimeProvider.now);
    final balance = (dailyLimit - spent).clamp(0, dailyLimit);

    print('[DopamineBalance] Лимит=$dailyLimit, потрачено=$spent, остаток=$balance');
    return balance;
  }
}