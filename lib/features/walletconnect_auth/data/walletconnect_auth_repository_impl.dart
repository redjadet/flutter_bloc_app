import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/data/walletconnect_service.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/wallet_address.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/walletconnect_auth_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Implementation of [WalletConnectAuthRepository].
class WalletConnectAuthRepositoryImpl implements WalletConnectAuthRepository {
  WalletConnectAuthRepositoryImpl({
    required final WalletConnectService walletConnectService,
    required final FirebaseAuth firebaseAuth,
    required final FirebaseFirestore firestore,
  }) : _walletConnectService = walletConnectService,
       _firebaseAuth = firebaseAuth,
       _firestore = firestore;

  final WalletConnectService _walletConnectService;
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  static const String _usersCollection = 'users';
  static const String _walletAddressField = 'walletAddress';
  static const String _connectedAtField = 'connectedAt';

  @override
  Future<WalletAddress> connectWallet() async {
    try {
      final address = await _walletConnectService.connect();
      AppLogger.debug(
        'WalletConnectAuthRepository: Wallet connected: ${address.truncated}',
      );
      return address;
    } on WalletConnectException {
      rethrow;
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'WalletConnectAuthRepository: connectWallet failed',
        error,
        stackTrace,
      );
      throw WalletConnectException('Failed to connect wallet', error);
    }
  }

  @override
  Future<void> linkWalletToFirebaseUser(final String walletAddress) async {
    try {
      // Ensure user is authenticated (create anonymous if needed)
      User user = _firebaseAuth.currentUser ?? await _createAnonymousUser();

      // Validate wallet address
      final address = WalletAddress(walletAddress);
      if (!address.isValid) {
        throw WalletConnectException(
          'Invalid wallet address format: $walletAddress',
        );
      }

      // Store wallet address in Firestore
      await _firestore.collection(_usersCollection).doc(user.uid).set(
        {
          _walletAddressField: walletAddress,
          _connectedAtField: FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // Optionally update user display name with wallet address
      try {
        await user.updateDisplayName(walletAddress);
        await user.reload();
        user = _firebaseAuth.currentUser!;
      } on Exception catch (error) {
        // Non-critical: display name update is optional
        AppLogger.warning('Failed to update user display name: $error');
      }

      AppLogger.debug(
        'WalletConnectAuthRepository: Wallet linked to user ${user.uid}: ${address.truncated}',
      );
    } on WalletConnectException {
      rethrow;
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'WalletConnectAuthRepository: linkWalletToFirebaseUser failed',
        error,
        stackTrace,
      );
      final detail = _firebaseErrorDetail(error);
      throw WalletConnectException(
        'Failed to link wallet to Firebase user.$detail',
        error,
      );
    }
  }

  /// Builds a user-visible detail string from Firebase/auth errors.
  static String _firebaseErrorDetail(final Object error) {
    if (error is FirebaseException) {
      final code = error.code;
      final msg = error.message?.trim();
      if (code.isNotEmpty || (msg != null && msg.isNotEmpty)) {
        final part = msg != null && msg.isNotEmpty ? '$code: $msg' : code;
        return ' $part';
      }
    }
    final s = error.toString().trim();
    if (s.isEmpty) return '';
    return ' $s';
  }

  @override
  Future<WalletAddress?> getLinkedWalletAddress() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return null;
      }

      final doc = await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data();
      final walletAddressStr = data?[_walletAddressField] as String?;

      if (walletAddressStr == null || walletAddressStr.isEmpty) {
        return null;
      }

      final address = WalletAddress(walletAddressStr);
      if (!address.isValid) {
        AppLogger.warning(
          'Invalid wallet address format in Firestore: $walletAddressStr',
        );
        return null;
      }

      return address;
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'WalletConnectAuthRepository: getLinkedWalletAddress failed',
        error,
        stackTrace,
      );
      return null;
    }
  }

  @override
  Future<void> disconnectWallet() async {
    try {
      await _walletConnectService.disconnect();
      AppLogger.debug('WalletConnectAuthRepository: Wallet disconnected');
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'WalletConnectAuthRepository: disconnectWallet failed',
        error,
        stackTrace,
      );
      // Don't rethrow - disconnection failures are non-critical
    }
  }

  /// Creates an anonymous Firebase Auth user if no user is authenticated.
  Future<User> _createAnonymousUser() async {
    try {
      final credential = await _firebaseAuth.signInAnonymously();
      AppLogger.debug(
        'WalletConnectAuthRepository: Created anonymous user: ${credential.user?.uid}',
      );
      return credential.user!;
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'WalletConnectAuthRepository: Failed to create anonymous user',
        error,
        stackTrace,
      );
      final detail = _firebaseErrorDetail(error);
      throw WalletConnectException(
        'Failed to create Firebase Auth user.$detail',
        error,
      );
    }
  }
}
