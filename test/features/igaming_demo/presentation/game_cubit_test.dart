import 'dart:math';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/igaming_demo/domain/demo_balance.dart';
import 'package:flutter_bloc_app/features/igaming_demo/domain/demo_balance_repository.dart';
import 'package:flutter_bloc_app/features/igaming_demo/domain/game_round_result.dart';
import 'package:flutter_bloc_app/features/igaming_demo/presentation/game_cubit.dart';
import 'package:flutter_bloc_app/features/igaming_demo/presentation/game_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_helpers.dart' show FakeTimerService;

class _StubDemoBalanceRepository implements DemoBalanceRepository {
  _StubDemoBalanceRepository({DemoBalance? initial})
    : _balance = initial ?? DemoBalance.initial();

  DemoBalance _balance;

  @override
  Future<DemoBalance> getBalance() async => _balance;

  @override
  Future<void> setBalance(final DemoBalance b) async {
    _balance = b;
  }

  @override
  Future<void> updateBalance(final int deltaUnits) async {
    _balance = DemoBalance(
      amountUnits: (_balance.amountUnits + deltaUnits).clamp(0, 1 << 62),
    );
  }
}

void main() {
  late FakeTimerService fakeTimer;

  group('GameCubit', () {
    blocTest<GameCubit, GameState>(
      'emits [idle] when loadBalance succeeds',
      build: () {
        final repo = _StubDemoBalanceRepository(
          initial: const DemoBalance(amountUnits: 1000),
        );
        return GameCubit(
          balanceRepository: repo,
          timerService: FakeTimerService(),
        );
      },
      act: (cubit) => cubit.loadBalance(),
      expect: () => <GameState>[
        GameState.idle(const DemoBalance(amountUnits: 1000), 100),
      ],
    );

    // Seed 13: nextBool() => false (loss), reels [4, 5, 2].
    blocTest<GameCubit, GameState>(
      'emits [spinning, result] when playRound runs',
      build: () {
        fakeTimer = FakeTimerService();
        final balanceRepo = _StubDemoBalanceRepository(
          initial: const DemoBalance(amountUnits: 1000),
        );
        return GameCubit(
          balanceRepository: balanceRepo,
          timerService: fakeTimer,
          random: Random(13),
        );
      },
      seed: () => GameState.idle(const DemoBalance(amountUnits: 1000), 100),
      act: (cubit) async {
        cubit.playRound();
        fakeTimer.elapse(kSpinAnimationDuration);
        await Future<void>.delayed(const Duration(milliseconds: 50));
      },
      expect: () => <GameState>[
        GameState.spinning(
          const DemoBalance(amountUnits: 1000),
          100,
          const <int>[4, 5, 2],
        ),
        GameState.result(
          const GameRoundResult(betAmount: 100, payoutAmount: 0, isWin: false),
          const DemoBalance(amountUnits: 900),
          100,
          const <int>[4, 5, 2],
        ),
      ],
    );

    blocTest<GameCubit, GameState>(
      'emits [error] when playRound with bet > balance',
      build: () {
        return GameCubit(
          balanceRepository: _StubDemoBalanceRepository(
            initial: const DemoBalance(amountUnits: 50),
          ),
          timerService: FakeTimerService(),
        );
      },
      seed: () => GameState.idle(const DemoBalance(amountUnits: 50), 100),
      act: (cubit) => cubit.playRound(),
      expect: () => <GameState>[const GameState.error('Insufficient balance')],
    );
  });
}
