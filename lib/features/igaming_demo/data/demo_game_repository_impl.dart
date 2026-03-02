import 'dart:math';

import 'package:flutter_bloc_app/features/igaming_demo/domain/demo_game_repository.dart';
import 'package:flutter_bloc_app/features/igaming_demo/domain/game_round_result.dart';

/// Demo implementation: 50% win chance; 2x payout on win, 0 on loss.
class DemoGameRepositoryImpl implements DemoGameRepository {
  @override
  Future<GameRoundResult> playRound({required final int betAmount}) async {
    final Random rng = Random();
    final bool isWin = rng.nextBool();
    final int payoutAmount = isWin ? betAmount * 2 : 0;
    return GameRoundResult(
      betAmount: betAmount,
      payoutAmount: payoutAmount,
      isWin: isWin,
    );
  }
}
