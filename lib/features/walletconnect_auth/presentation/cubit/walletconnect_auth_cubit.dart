import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/walletconnect_auth_repository.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/presentation/cubit/walletconnect_auth_state.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';

/// Cubit managing WalletConnect authentication state.
class WalletConnectAuthCubit extends Cubit<WalletConnectAuthState> {
  WalletConnectAuthCubit({
    required final WalletConnectAuthRepository repository,
  }) : _repository = repository,
       super(const WalletConnectAuthState());

  final WalletConnectAuthRepository _repository;

  /// Loads the linked wallet address if available.
  Future<void> loadLinkedWallet() async {
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () async {
        if (isClosed) return;
        emit(state.copyWith(status: ViewStatus.loading));

        final linkedAddress = await _repository.getLinkedWalletAddress();
        if (isClosed) return;

        emit(
          state.copyWith(
            status: ViewStatus.success,
            linkedWalletAddress: linkedAddress,
          ),
        );
      },
      onError: (final message) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: ViewStatus.error,
            errorMessage: message,
          ),
        );
      },
      logContext: 'WalletConnectAuthCubit.loadLinkedWallet',
    );
  }

  /// Connects to a wallet via WalletConnect.
  Future<void> connectWallet() async {
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () async {
        if (isClosed) return;
        emit(state.copyWith(status: ViewStatus.loading, errorMessage: null));

        final address = await _repository.connectWallet();
        if (isClosed) return;

        emit(
          state.copyWith(
            status: ViewStatus.success,
            walletAddress: address,
            errorMessage: null,
          ),
        );
      },
      onError: (final message) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: ViewStatus.error,
            errorMessage: message,
            walletAddress: null,
          ),
        );
      },
      logContext: 'WalletConnectAuthCubit.connectWallet',
    );
  }

  /// Links the connected wallet to the Firebase Auth user.
  Future<void> linkWalletToUser() async {
    final currentAddress = state.walletAddress;
    if (currentAddress == null) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ViewStatus.error,
          errorMessage: 'No wallet connected. Please connect a wallet first.',
        ),
      );
      return;
    }

    await CubitExceptionHandler.executeAsyncVoid(
      operation: () async {
        if (isClosed) return;
        emit(state.copyWith(status: ViewStatus.loading, errorMessage: null));

        await _repository.linkWalletToFirebaseUser(currentAddress.value);
        if (isClosed) return;

        // Reload linked address
        final linkedAddress = await _repository.getLinkedWalletAddress();
        if (isClosed) return;

        emit(
          state.copyWith(
            status: ViewStatus.success,
            linkedWalletAddress: linkedAddress,
            errorMessage: null,
          ),
        );
      },
      onError: (final message) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: ViewStatus.error,
            errorMessage: message,
          ),
        );
      },
      logContext: 'WalletConnectAuthCubit.linkWalletToUser',
    );
  }

  /// Disconnects the wallet.
  Future<void> disconnectWallet() async {
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () async {
        if (isClosed) return;
        emit(state.copyWith(status: ViewStatus.loading, errorMessage: null));

        await _repository.disconnectWallet();
        if (isClosed) return;

        emit(
          state.copyWith(
            status: ViewStatus.initial,
            walletAddress: null,
            errorMessage: null,
          ),
        );
      },
      onError: (final message) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: ViewStatus.error,
            errorMessage: message,
          ),
        );
      },
      logContext: 'WalletConnectAuthCubit.disconnectWallet',
    );
  }

  /// Clears the error message.
  void clearError() {
    if (isClosed) return;
    if (state.errorMessage == null) return;

    emit(
      state.copyWith(
        errorMessage: null,
        status: state.walletAddress != null
            ? ViewStatus.success
            : ViewStatus.initial,
      ),
    );
  }
}
