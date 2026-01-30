import 'package:flutter_bloc_app/features/walletconnect_auth/domain/wallet_address.dart';

/// Repository contract for WalletConnect authentication.
///
/// Handles wallet connection via WalletConnect and linking to Firebase Auth.
abstract class WalletConnectAuthRepository {
  /// Initiates a WalletConnect session and returns the connected wallet address.
  ///
  /// Throws [WalletConnectException] if connection fails.
  Future<WalletAddress> connectWallet();

  /// Links the wallet address to the current Firebase Auth user.
  ///
  /// Creates an anonymous user if not authenticated.
  /// Stores the wallet address in Firestore and optionally updates user profile.
  ///
  /// Throws [WalletConnectException] if linking fails.
  Future<void> linkWalletToFirebaseUser(final String walletAddress);

  /// Retrieves the linked wallet address for the current Firebase Auth user.
  ///
  /// Returns `null` if no wallet is linked or user is not authenticated.
  Future<WalletAddress?> getLinkedWalletAddress();

  /// Disconnects the WalletConnect session.
  ///
  /// Does not sign out the Firebase Auth user.
  Future<void> disconnectWallet();
}

/// Exception thrown by WalletConnect operations.
class WalletConnectException implements Exception {
  const WalletConnectException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() =>
      'WalletConnectException: $message${cause != null ? ' (caused by: $cause)' : ''}';
}
