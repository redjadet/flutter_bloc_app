import 'package:flutter_bloc_app/features/igaming_demo/domain/demo_balance.dart';
import 'package:flutter_bloc_app/features/igaming_demo/domain/game_round_result.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_state.freezed.dart';

/// State for the play-for-fun game screen (stake, round, result).
@freezed
abstract class GameState with _$GameState {
  const GameState._();

  const factory GameState.idle(
    DemoBalance balance,
    int selectedStake,
  ) = _GameIdle;
  const factory GameState.placingBet(
    DemoBalance balance,
    int selectedStake,
  ) = _GamePlacingBet;
  const factory GameState.spinning(
    DemoBalance balance,
    int bet,
    List<int> targetReelSymbolIndices,
  ) = _GameSpinning;
  const factory GameState.result(
    GameRoundResult roundResult,
    DemoBalance newBalance,
    int selectedStake,
    List<int> targetReelSymbolIndices,
  ) = _GameResult;
  const factory GameState.error(String message) = _GameError;

  /// Current balance when in idle, placingBet, spinning, or result; null otherwise.
  DemoBalance? get balanceOrNull => mapOrNull(
    idle: (s) => s.balance,
    placingBet: (s) => s.balance,
    spinning: (s) => s.balance,
    result: (s) => s.newBalance,
    error: (_) => null,
  );

  /// Selected stake when in idle, placingBet, spinning (bet), or result; null otherwise.
  int? get selectedStakeOrNull => mapOrNull(
    idle: (s) => s.selectedStake,
    placingBet: (s) => s.selectedStake,
    spinning: (s) => s.bet,
    result: (s) => s.selectedStake,
    error: (_) => null,
  );

  /// Target symbol index per reel (0..symbolCount-1) when spinning or in result; empty otherwise.
  List<int> get targetReelSymbolIndicesOrEmpty =>
      mapOrNull(
        spinning: (s) => s.targetReelSymbolIndices,
        result: (s) => s.targetReelSymbolIndices,
        idle: (_) => null,
        placingBet: (_) => null,
        error: (_) => null,
      ) ??
      const <int>[];
}
