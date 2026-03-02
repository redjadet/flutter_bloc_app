import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/igaming_demo/domain/demo_balance.dart';
import 'package:flutter_bloc_app/features/igaming_demo/domain/demo_balance_repository.dart';
import 'package:flutter_bloc_app/features/igaming_demo/presentation/lobby_cubit.dart';
import 'package:flutter_bloc_app/features/igaming_demo/presentation/lobby_state.dart';

class _StubDemoBalanceRepository implements DemoBalanceRepository {
  _StubDemoBalanceRepository({this.balance, this.throwOnGet});

  final DemoBalance? balance;
  final Exception? throwOnGet;

  @override
  Future<DemoBalance> getBalance() async {
    final Exception? e = throwOnGet;
    if (e != null) throw e;
    return balance ?? DemoBalance.initial();
  }

  @override
  Future<void> setBalance(final DemoBalance b) async {}

  @override
  Future<void> updateBalance(final int deltaUnits) async {}
}

void main() {
  group('LobbyCubit', () {
    blocTest<LobbyCubit, LobbyState>(
      'emits [loading, ready] when loadBalance succeeds',
      build: () => LobbyCubit(
        repository: _StubDemoBalanceRepository(
          balance: const DemoBalance(amountUnits: 5000),
        ),
      ),
      act: (cubit) => cubit.loadBalance(),
      expect: () => <LobbyState>[
        const LobbyState.loading(),
        LobbyState.ready(const DemoBalance(amountUnits: 5000)),
      ],
    );

    blocTest<LobbyCubit, LobbyState>(
      'emits [loading, error] when getBalance throws',
      build: () => LobbyCubit(
        repository: _StubDemoBalanceRepository(
          throwOnGet: Exception('load failed'),
        ),
      ),
      act: (cubit) => cubit.loadBalance(),
      expect: () => <LobbyState>[
        const LobbyState.loading(),
        LobbyState.error('Exception: load failed'),
      ],
    );
  });
}
