import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_round_result.freezed.dart';

/// Result of one play-for-fun game round.
@freezed
abstract class GameRoundResult with _$GameRoundResult {
  const factory GameRoundResult({
    required final int betAmount,
    required final int payoutAmount,
    required final bool isWin,
  }) = _GameRoundResult;

  const GameRoundResult._();

  /// Net change in balance (payout - bet); positive on win, negative on loss.
  int get netChange => payoutAmount - betAmount;
}
