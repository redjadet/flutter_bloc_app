import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/wallet_address.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/wallet_user_profile.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/walletconnect_auth_repository.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/presentation/cubit/walletconnect_auth_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';

/// Cubit managing WalletConnect authentication state.
class WalletConnectAuthCubit extends Cubit<WalletConnectAuthState> {
  WalletConnectAuthCubit({
    required final WalletConnectAuthRepository repository,
    final AppLocalizations? l10n,
  }) : _repository = repository,
       _l10n = l10n,
       super(const WalletConnectAuthState());

  final WalletConnectAuthRepository _repository;
  final AppLocalizations? _l10n;

  /// Loads the linked wallet address if available.
  Future<void> loadLinkedWallet() async {
    await _runLoadingAction(
      logContext: 'WalletConnectAuthCubit.loadLinkedWallet',
      clearError: false,
      operation: _refreshLinkedWalletState,
    );
  }

  /// Connects to a wallet via WalletConnect.
  Future<void> connectWallet() async {
    await _runLoadingAction(
      logContext: 'WalletConnectAuthCubit.connectWallet',
      operation: () async {
        final address = await _repository.connectWallet();
        _emitSuccess(
          state.copyWith(
            walletAddress: address,
            errorMessage: null,
          ),
        );
      },
      onError: (final message) {
        _emitError(
          message,
          nextState: state.copyWith(walletAddress: null),
        );
      },
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
          errorMessage:
              _l10n?.noWalletConnected ??
              'No wallet connected. Please connect a wallet first.',
        ),
      );
      return;
    }

    await _runLoadingAction(
      logContext: 'WalletConnectAuthCubit.linkWalletToUser',
      operation: () async {
        await _repository.linkWalletToFirebaseUser(currentAddress.value);
        await _refreshLinkedWalletState();
      },
    );
  }

  /// Disconnects the wallet.
  Future<void> disconnectWallet() async {
    await _runLoadingAction(
      logContext: 'WalletConnectAuthCubit.disconnectWallet',
      operation: () async {
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
    );
  }

  /// Re-links the already-linked wallet to the Firebase Auth user (e.g. to refresh profile doc).
  Future<void> relinkWalletToUser() async {
    final linkedAddress = state.linkedWalletAddress;
    if (linkedAddress == null) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ViewStatus.error,
          errorMessage:
              _l10n?.noWalletLinked ??
              'No wallet linked. Connect and link first.',
        ),
      );
      return;
    }

    await _runLoadingAction(
      logContext: 'WalletConnectAuthCubit.relinkWalletToUser',
      operation: () async {
        await _repository.linkWalletToFirebaseUser(linkedAddress.value);
        await _refreshLinkedWalletState();
      },
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

  Future<void> _runLoadingAction({
    required final String logContext,
    required final Future<void> Function() operation,
    final void Function(String message)? onError,
    final bool clearError = true,
  }) async {
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () async {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: ViewStatus.loading,
            errorMessage: clearError ? null : state.errorMessage,
          ),
        );
        await operation();
      },
      isAlive: () => !isClosed,
      onError: onError ?? _emitError,
      logContext: logContext,
    );
  }

  Future<void> _refreshLinkedWalletState() async {
    final linkedAddress = await _repository.getLinkedWalletAddress();
    if (isClosed) return;

    final WalletUserProfile? profile = await _loadUserProfile(linkedAddress);
    if (isClosed) return;

    _emitSuccess(
      state.copyWith(
        linkedWalletAddress: linkedAddress,
        userProfile: profile,
        errorMessage: null,
      ),
    );
  }

  Future<WalletUserProfile?> _loadUserProfile(
    final WalletAddress? linkedAddress,
  ) async {
    if (linkedAddress == null) {
      return null;
    }
    return _repository.getWalletUserProfile(linkedAddress.value);
  }

  void _emitSuccess(final WalletConnectAuthState nextState) {
    if (isClosed) return;
    emit(nextState.copyWith(status: ViewStatus.success));
  }

  void _emitError(
    final String message, {
    final WalletConnectAuthState? nextState,
  }) {
    if (isClosed) return;
    emit(
      (nextState ?? state).copyWith(
        status: ViewStatus.error,
        errorMessage: message,
      ),
    );
  }
}
