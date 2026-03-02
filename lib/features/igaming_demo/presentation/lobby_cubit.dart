import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/igaming_demo/domain/demo_balance.dart';
import 'package:flutter_bloc_app/features/igaming_demo/domain/demo_balance_repository.dart';
import 'package:flutter_bloc_app/features/igaming_demo/presentation/lobby_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';

/// Cubit for the iGaming demo lobby: loads and displays virtual balance.
class LobbyCubit extends Cubit<LobbyState> {
  LobbyCubit({
    required final DemoBalanceRepository repository,
    final AppLocalizations? l10n,
  }) : _repository = repository,
       _l10n = l10n,
       super(const LobbyState.initial());

  final DemoBalanceRepository _repository;
  final AppLocalizations? _l10n;

  Future<void> loadBalance() async {
    if (isClosed) return;
    emit(const LobbyState.loading());
    await CubitExceptionHandler.executeAsync<DemoBalance>(
      operation: () => _repository.getBalance(),
      isAlive: () => !isClosed,
      onSuccess: (final balance) {
        if (isClosed) return;
        emit(LobbyState.ready(balance));
      },
      onError: (final message) {
        if (isClosed) return;
        emit(
          LobbyState.error(_l10n?.igamingDemoErrorLoadBalance ?? message),
        );
      },
      logContext: 'LobbyCubit.loadBalance',
    );
  }
}
