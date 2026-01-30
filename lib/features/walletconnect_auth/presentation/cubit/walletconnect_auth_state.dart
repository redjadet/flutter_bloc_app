import 'package:flutter_bloc_app/features/walletconnect_auth/domain/wallet_address.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'walletconnect_auth_state.freezed.dart';

@freezed
abstract class WalletConnectAuthState with _$WalletConnectAuthState {
  const factory WalletConnectAuthState({
    @Default(ViewStatus.initial) final ViewStatus status,
    final WalletAddress? walletAddress,
    final WalletAddress? linkedWalletAddress,
    final String? errorMessage,
  }) = _WalletConnectAuthState;

  const WalletConnectAuthState._();

  /// Whether a wallet is currently connected.
  bool get isConnected => walletAddress != null;

  /// Whether the wallet is linked to Firebase Auth.
  bool get isLinked => linkedWalletAddress != null;

  /// Whether the connection is in progress.
  bool get isConnecting =>
      status == ViewStatus.loading && walletAddress == null;

  /// Whether linking is in progress.
  bool get isLinking =>
      status == ViewStatus.loading && walletAddress != null && !isLinked;
}
