import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/data/wallet_user_profile_mapper.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/data/walletconnect_service.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/wallet_address.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/wallet_user_profile.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/walletconnect_auth_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/safe_parse_utils.dart';

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
  static const String _walletAddressNormalizedField = 'walletAddressNormalized';
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

      // Store linkage + profile in a single document at users/{uid} (one doc per user)
      final normalizedWallet = _normalizeWalletDocId(walletAddress);
      final Map<String, Object?> userData = {
        _walletAddressField: walletAddress,
        _walletAddressNormalizedField: normalizedWallet,
        _connectedAtField: FieldValue.serverTimestamp(),
        ...WalletUserProfileMapper.defaultFirestoreMap(),
      };
      userData[WalletUserProfileFields.updatedAt] =
          FieldValue.serverTimestamp();
      await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .set(
            userData,
            SetOptions(merge: true),
          );

      // Optionally update user display name with wallet address
      try {
        await user.updateDisplayName(walletAddress);
        await user.reload();
        final User? updated = _firebaseAuth.currentUser;
        if (updated case final latestUser?) user = latestUser;
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
      final walletAddressStr = stringFromDynamic(data?[_walletAddressField]);

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

  @override
  Future<void> upsertWalletUserProfile(
    final String walletAddress, {
    final WalletUserProfile? profile,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const WalletConnectException(
          'Not authenticated. Sign in before upserting profile.',
        );
      }
      final linked = await getLinkedWalletAddress();
      final normalized = _normalizeWalletDocId(walletAddress);
      if (linked == null || _normalizeWalletDocId(linked.value) != normalized) {
        throw WalletConnectException(
          'Wallet $walletAddress is not linked to the current user.',
        );
      }
      final Map<String, Object?> data = profile != null
          ? WalletUserProfileMapper.toFirestore(profile)
          : WalletUserProfileMapper.defaultFirestoreMap();
      data[WalletUserProfileFields.updatedAt] = FieldValue.serverTimestamp();
      await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .set(
            data,
            SetOptions(merge: true),
          );
      AppLogger.debug(
        'WalletConnectAuthRepository: Upserted profile for ${WalletAddress(walletAddress).truncated}',
      );
    } on WalletConnectException {
      rethrow;
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'WalletConnectAuthRepository: upsertWalletUserProfile failed',
        error,
        stackTrace,
      );
      final detail = _firebaseErrorDetail(error);
      throw WalletConnectException(
        'Failed to upsert wallet user profile.$detail',
        error,
      );
    }
  }

  @override
  Future<WalletUserProfile?> getWalletUserProfile(
    final String walletAddress,
  ) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;
      final linked = await getLinkedWalletAddress();
      final normalized = _normalizeWalletDocId(walletAddress);
      if (linked == null || _normalizeWalletDocId(linked.value) != normalized) {
        return null;
      }
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .get();
      if (!doc.exists) return null;
      final data = doc.data();
      return WalletUserProfileMapper.fromFirestore(
        data != null ? Map<String, dynamic>.from(data) : null,
      );
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'WalletConnectAuthRepository: getWalletUserProfile failed',
        error,
        stackTrace,
      );
      return null;
    }
  }

  /// Normalizes wallet address for use as Firestore document ID (e.g. lowercase).
  static String _normalizeWalletDocId(final String walletAddress) =>
      walletAddress.toLowerCase();

  /// Creates an anonymous Firebase Auth user if no user is authenticated.
  Future<User> _createAnonymousUser() async {
    try {
      final credential = await _firebaseAuth.signInAnonymously();
      final User? newUser = credential.user;
      if (newUser == null) {
        throw WalletConnectException(
          'Failed to create Firebase Auth user: no user in credential',
          StateError('signInAnonymously returned null user'),
        );
      }
      AppLogger.debug(
        'WalletConnectAuthRepository: Created anonymous user: ${newUser.uid}',
      );
      return newUser;
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
