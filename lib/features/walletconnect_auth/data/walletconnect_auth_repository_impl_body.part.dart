part of 'walletconnect_auth_repository_impl.dart';

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
      User user = await _requireAuthenticatedUser();
      final WalletAddress address = _requireValidWalletAddress(walletAddress);

      final Map<String, Object?> userData = {
        _walletAddressField: address.value,
        _walletAddressNormalizedField: _normalizeWalletDocId(address.value),
        _connectedAtField: FieldValue.serverTimestamp(),
        ...WalletUserProfileMapper.defaultFirestoreMap(),
      };
      userData[WalletUserProfileFields.updatedAt] =
          FieldValue.serverTimestamp();
      await _userDocument(user.uid).set(userData, SetOptions(merge: true));

      try {
        await user.updateDisplayName(address.value);
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

      final doc = await _userDocument(user.uid).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data();
      final walletAddressStr = stringFromDynamic(data?[_walletAddressField]);

      if (walletAddressStr == null || walletAddressStr.isEmpty) {
        return null;
      }

      return _parseLinkedWalletAddress(walletAddressStr);
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
      final User user = _requireCurrentUserForProfileWrite();
      final WalletAddress linkedWallet = await _requireLinkedWalletAddress(
        walletAddress,
      );
      final Map<String, Object?> data = profile != null
          ? WalletUserProfileMapper.toFirestore(profile)
          : WalletUserProfileMapper.defaultFirestoreMap();
      data[WalletUserProfileFields.updatedAt] = FieldValue.serverTimestamp();
      await _userDocument(user.uid).set(data, SetOptions(merge: true));
      AppLogger.debug(
        'WalletConnectAuthRepository: Upserted profile for ${linkedWallet.truncated}',
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
      final WalletAddress? linkedWallet =
          await _linkedWalletAddressForCurrentUser(
            walletAddress,
          );
      if (linkedWallet == null) {
        return null;
      }
      final doc = await _userDocument(user.uid).get();
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

  DocumentReference<Map<String, dynamic>> _userDocument(final String uid) =>
      _firestore.collection(_usersCollection).doc(uid);

  Future<User> _requireAuthenticatedUser() async =>
      _firebaseAuth.currentUser ?? await _createAnonymousUser();

  User _requireCurrentUserForProfileWrite() {
    final User? user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const WalletConnectException(
        'Not authenticated. Sign in before upserting profile.',
      );
    }
    return user;
  }

  WalletAddress _requireValidWalletAddress(final String walletAddress) {
    final WalletAddress address = WalletAddress(walletAddress);
    if (!address.isValid) {
      throw WalletConnectException(
        'Invalid wallet address format: $walletAddress',
      );
    }
    return address;
  }

  WalletAddress? _parseLinkedWalletAddress(final String walletAddress) {
    final WalletAddress address = WalletAddress(walletAddress);
    if (address.isValid) {
      return address;
    }
    AppLogger.warning(
      'Invalid wallet address format in Firestore: $walletAddress',
    );
    return null;
  }

  Future<WalletAddress?> _linkedWalletAddressForCurrentUser(
    final String walletAddress,
  ) async {
    final WalletAddress? linked = await getLinkedWalletAddress();
    if (linked == null) {
      return null;
    }
    return _normalizeWalletDocId(linked.value) ==
            _normalizeWalletDocId(walletAddress)
        ? linked
        : null;
  }

  Future<WalletAddress> _requireLinkedWalletAddress(
    final String walletAddress,
  ) async {
    final WalletAddress? linked = await _linkedWalletAddressForCurrentUser(
      walletAddress,
    );
    if (linked != null) {
      return linked;
    }
    throw WalletConnectException(
      'Wallet $walletAddress is not linked to the current user.',
    );
  }

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
