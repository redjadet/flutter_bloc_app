import 'package:flutter_bloc_app/features/igaming_demo/domain/game_round_result.dart';

/// Runs one play-for-fun game round. No side effects on balance; caller applies result.
abstract class DemoGameRepository {
  Future<GameRoundResult> playRound({required final int betAmount});
}
