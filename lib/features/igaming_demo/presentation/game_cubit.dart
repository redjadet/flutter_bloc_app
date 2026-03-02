import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/igaming_demo/domain/demo_balance.dart';
import 'package:flutter_bloc_app/features/igaming_demo/domain/demo_balance_repository.dart';
import 'package:flutter_bloc_app/features/igaming_demo/domain/game_round_result.dart';
import 'package:flutter_bloc_app/features/igaming_demo/presentation/game_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';

/// Duration of the spin animation before the round result is resolved.
const Duration kSpinAnimationDuration = Duration(milliseconds: 2500);

/// Cubit for one play-for-fun game round: stake, play, result, balance update.
class GameCubit extends Cubit<GameState> {
  GameCubit({
    required final DemoBalanceRepository balanceRepository,
    required final TimerService timerService,
    final Random? random,
    final AppLocalizations? l10n,
  }) : _balanceRepository = balanceRepository,
       _timerService = timerService,
       _testRandom = random,
       _l10n = l10n,
       super(
         GameState.error(
           l10n?.igamingDemoErrorLoadBalance ?? _defaultLoadBalanceError,
         ),
       );

  final DemoBalanceRepository _balanceRepository;
  final TimerService _timerService;
  final AppLocalizations? _l10n;

  /// When set (e.g. in tests), used for deterministic outcomes. Otherwise each spin uses a fresh time-based RNG.
  final Random? _testRandom;

  TimerDisposable? _spinHandle;

  static const int _defaultStake = 100;
  static const String _defaultLoadBalanceError = 'Failed to load balance';
  static const String _defaultInsufficientBalanceError = 'Insufficient balance';

  /// Sets the stake amount for the next round (used by UI).
  void setStake(final int amount) {
    if (isClosed) return;
    final DemoBalance? balance = state.balanceOrNull;
    if (balance != null && !isClosed) {
      emit(GameState.idle(balance, amount));
    }
  }

  /// Loads current balance and switches to Idle (call from route init).
  Future<void> loadBalance() async {
    if (isClosed) return;
    await CubitExceptionHandler.executeAsync<DemoBalance>(
      operation: () => _balanceRepository.getBalance(),
      isAlive: () => !isClosed,
      onSuccess: (final balance) {
        if (isClosed) return;
        emit(GameState.idle(balance, _defaultStake));
      },
      onError: (final message) {
        if (isClosed) return;
        emit(
          GameState.error(_l10n?.igamingDemoErrorLoadBalance ?? message),
        );
      },
      logContext: 'GameCubit.loadBalance',
    );
  }

  static const int _symbolCount = 6;

  /// Picks three reel symbol indices: all same (win) or not all same (loss). 50% win chance.
  List<int> _pickTargetReelSymbolIndices(final Random rng) {
    final bool isWin = rng.nextBool();
    if (isWin) {
      final int s = rng.nextInt(_symbolCount);
      return <int>[s, s, s];
    }
    final int a = rng.nextInt(_symbolCount);
    int b = rng.nextInt(_symbolCount);
    while (b == a) {
      b = rng.nextInt(_symbolCount);
    }
    final int c = rng.nextInt(_symbolCount);
    return <int>[a, b, c];
  }

  /// Starts a spin: picks outcome (three matching = win), emits spinning, then resolves after animation.
  /// Uses a fresh RNG per spin (time-based seed) so each spin result is randomized; tests can inject a fixed Random.
  void playRound() {
    if (isClosed) return;
    final DemoBalance? balance = state.balanceOrNull;
    final int? stake = state.selectedStakeOrNull;
    if (balance == null || stake == null) return;
    final int bet = stake;
    if (bet <= 0 || bet > balance.amountUnits) {
      if (isClosed) return;
      emit(
        GameState.error(
          _l10n?.igamingDemoErrorInsufficientBalance ??
              _defaultInsufficientBalanceError,
        ),
      );
      return;
    }
    if (isClosed) return;
    _spinHandle?.dispose();
    final Random rng =
        _testRandom ?? Random(DateTime.now().microsecondsSinceEpoch);
    final List<int> target = _pickTargetReelSymbolIndices(rng);
    emit(GameState.spinning(balance, bet, target));
    _spinHandle = _timerService.runOnce(
      kSpinAnimationDuration,
      _resolveRoundAfterSpin,
    );
  }

  void _resolveRoundAfterSpin() {
    if (isClosed) return;
    _spinHandle = null;
    final (int, List<int>)? spinData = state.mapOrNull(
      spinning: (final s) => (s.bet, s.targetReelSymbolIndices),
    );
    if (spinData == null) {
      return;
    }
    final int betAmount = spinData.$1;
    final List<int> indices = spinData.$2;
    if (indices.length != 3) {
      return;
    }
    final bool isWin = indices[0] == indices[1] && indices[1] == indices[2];
    final GameRoundResult roundResult = GameRoundResult(
      betAmount: betAmount,
      payoutAmount: isWin ? betAmount * 2 : 0,
      isWin: isWin,
    );
    unawaited(
      CubitExceptionHandler.executeAsync<DemoBalance>(
        operation: () async {
          await _balanceRepository.updateBalance(roundResult.netChange);
          return _balanceRepository.getBalance();
        },
        isAlive: () => !isClosed,
        onSuccess: (final newBalance) {
          if (isClosed) return;
          emit(
            GameState.result(
              roundResult,
              newBalance,
              betAmount,
              indices,
            ),
          );
        },
        onError: (final message) {
          if (isClosed) return;
          emit(
            GameState.error(_l10n?.igamingDemoErrorLoadBalance ?? message),
          );
        },
        logContext: 'GameCubit._resolveRoundAfterSpin',
      ),
    );
  }

  @override
  Future<void> close() {
    _spinHandle?.dispose();
    _spinHandle = null;
    return super.close();
  }

  /// Resets to Idle with current balance after showing result (Play again).
  void playAgain() {
    if (isClosed) return;
    state.when(
      idle: (final balance, final stake) {},
      placingBet: (final balance, final stake) {},
      spinning: (final balance, final bet, final _) {},
      result:
          (final roundResult, final newBalance, final selectedStake, final _) {
            if (isClosed) return;
            emit(GameState.idle(newBalance, selectedStake));
          },
      error: (_) {},
    );
  }
}
