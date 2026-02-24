import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
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
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () async {
        if (isClosed) return;
        emit(state.copyWith(status: ViewStatus.loading));

        final linkedAddress = await _repository.getLinkedWalletAddress();
        if (isClosed) return;

        WalletUserProfile? profile;
        if (linkedAddress != null) {
          profile = await _repository.getWalletUserProfile(linkedAddress.value);
          if (isClosed) return;
        }

        emit(
          state.copyWith(
            status: ViewStatus.success,
            linkedWalletAddress: linkedAddress,
            userProfile: profile,
          ),
        );
      },
      isAlive: () => !isClosed,
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
      isAlive: () => !isClosed,
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
          errorMessage:
              _l10n?.noWalletConnected ??
              'No wallet connected. Please connect a wallet first.',
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

        final linkedAddress = await _repository.getLinkedWalletAddress();
        if (isClosed) return;

        WalletUserProfile? profile;
        if (linkedAddress != null) {
          profile = await _repository.getWalletUserProfile(linkedAddress.value);
          if (isClosed) return;
        }

        emit(
          state.copyWith(
            status: ViewStatus.success,
            linkedWalletAddress: linkedAddress,
            userProfile: profile,
            errorMessage: null,
          ),
        );
      },
      isAlive: () => !isClosed,
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
      isAlive: () => !isClosed,
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

    await CubitExceptionHandler.executeAsyncVoid(
      operation: () async {
        if (isClosed) return;
        emit(state.copyWith(status: ViewStatus.loading, errorMessage: null));

        await _repository.linkWalletToFirebaseUser(linkedAddress.value);
        if (isClosed) return;

        final updated = await _repository.getLinkedWalletAddress();
        if (isClosed) return;

        WalletUserProfile? profile;
        if (updated != null) {
          profile = await _repository.getWalletUserProfile(updated.value);
          if (isClosed) return;
        }

        emit(
          state.copyWith(
            status: ViewStatus.success,
            linkedWalletAddress: updated,
            userProfile: profile,
            errorMessage: null,
          ),
        );
      },
      isAlive: () => !isClosed,
      onError: (final message) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: ViewStatus.error,
            errorMessage: message,
          ),
        );
      },
      logContext: 'WalletConnectAuthCubit.relinkWalletToUser',
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
