import 'package:flutter_bloc_app/features/igaming_demo/domain/demo_balance.dart';
import 'package:flutter_bloc_app/features/igaming_demo/domain/game_round_result.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_state.freezed.dart';

/// State for the play-for-fun game screen (stake, round, result).
@freezed
abstract class GameState with _$GameState {
  const GameState._();

  const factory GameState.idle(
    final DemoBalance balance,
    final int selectedStake,
  ) = _GameIdle;
  const factory GameState.placingBet(
    final DemoBalance balance,
    final int selectedStake,
  ) = _GamePlacingBet;
  const factory GameState.spinning(
    final DemoBalance balance,
    final int bet,
    final List<int> targetReelSymbolIndices,
  ) = _GameSpinning;
  const factory GameState.result(
    final GameRoundResult roundResult,
    final DemoBalance newBalance,
    final int selectedStake,
    final List<int> targetReelSymbolIndices,
  ) = _GameResult;
  const factory GameState.error(final String message) = _GameError;

  /// Current balance when in idle, placingBet, spinning, or result; null otherwise.
  DemoBalance? get balanceOrNull => mapOrNull(
    idle: (final s) => s.balance,
    placingBet: (final s) => s.balance,
    spinning: (final s) => s.balance,
    result: (final s) => s.newBalance,
    error: (_) => null,
  );

  /// Selected stake when in idle, placingBet, spinning (bet), or result; null otherwise.
  int? get selectedStakeOrNull => mapOrNull(
    idle: (final s) => s.selectedStake,
    placingBet: (final s) => s.selectedStake,
    spinning: (final s) => s.bet,
    result: (final s) => s.selectedStake,
    error: (_) => null,
  );

  /// Target symbol index per reel (0..symbolCount-1) when spinning or in result; empty otherwise.
  List<int> get targetReelSymbolIndicesOrEmpty =>
      mapOrNull(
        spinning: (final s) => s.targetReelSymbolIndices,
        result: (final s) => s.targetReelSymbolIndices,
        idle: (_) => null,
        placingBet: (_) => null,
        error: (_) => null,
      ) ??
      const <int>[];
}
