part of 'register_auth_services.dart';

bool get _shouldUseDebugKeychainGuestFallback {
  if (kIsWeb || kReleaseMode) {
    return false;
  }
  if (defaultTargetPlatform == TargetPlatform.macOS) {
    return true;
  }
  return defaultTargetPlatform == TargetPlatform.iOS &&
      FirebaseBootstrapService.isIosSimulatorInDebug;
}

class _DebugKeychainGuestAuthRepository extends FirebaseAuthRepository {
  _DebugKeychainGuestAuthRepository({required super.firebaseAuth}) {
    _firebaseSubscription = super.authStateChanges.listen((final user) {
      if (user != null) {
        _localGuest = null;
      }
      _authStateController.add(currentUser);
    });
  }

  final StreamController<AuthUser?> _authStateController =
      StreamController<AuthUser?>.broadcast();
  StreamSubscription<AuthUser?>? _firebaseSubscription;
  AuthUser? _localGuest;

  String get _localGuestId => defaultTargetPlatform == TargetPlatform.macOS
      ? 'macos-debug-local-guest'
      : 'ios-simulator-debug-local-guest';

  @override
  AuthUser? get currentUser => super.currentUser ?? _localGuest;

  @override
  Stream<AuthUser?> get authStateChanges async* {
    yield currentUser;
    yield* _authStateController.stream;
  }

  @override
  Future<void> signInAnonymously() async {
    try {
      await super.signInAnonymously();
    } on Exception catch (error) {
      if (!_looksLikeKeychainEntitlementError(error)) {
        rethrow;
      }
      _localGuest = AuthUser(id: _localGuestId, isAnonymous: true);
      _authStateController.add(_localGuest);
    }
  }

  @override
  Future<void> signOut() async {
    _localGuest = null;
    _authStateController.add(null);
    try {
      await super.signOut();
    } on Exception catch (error) {
      if (!_looksLikeKeychainEntitlementError(error)) {
        rethrow;
      }
    }
  }

  Future<void> dispose() async {
    await _firebaseSubscription?.cancel();
    await _authStateController.close();
  }
}

/// Local-only guest session when Firebase Auth is unavailable.
///
/// Web: enabled via [BackendAvailability.allowWebLocalGuestAuth] (including release).
/// Non-web: enabled via existing debug/simulator policy gates.
class _LocalGuestOnlyAuthRepository implements AuthRepository {
  _LocalGuestOnlyAuthRepository({this.localGuestIdOverride});

  final String? localGuestIdOverride;

  final StreamController<AuthUser?> _authStateController =
      StreamController<AuthUser?>.broadcast();
  AuthUser? _localGuest;

  String get _localGuestId {
    final String? override = localGuestIdOverride;
    if (override != null) {
      return override;
    }
    if (kIsWeb) {
      return 'web-local-guest';
    }
    return defaultTargetPlatform == TargetPlatform.macOS
        ? 'macos-debug-local-guest'
        : 'ios-simulator-debug-local-guest';
  }

  @override
  AuthUser? get currentUser => _localGuest;

  @override
  Stream<AuthUser?> get authStateChanges async* {
    yield currentUser;
    yield* _authStateController.stream;
  }

  @override
  Future<void> signInAnonymously() async {
    _localGuest = AuthUser(id: _localGuestId, isAnonymous: true);
    _authStateController.add(_localGuest);
  }

  @override
  Future<void> signOut() async {
    _localGuest = null;
    _authStateController.add(null);
  }

  Future<void> dispose() async {
    await _authStateController.close();
  }
}

class _UnavailableAuthRepository implements AuthRepository {
  const _UnavailableAuthRepository();

  @override
  AuthUser? get currentUser => null;

  @override
  Stream<AuthUser?> get authStateChanges => const Stream<AuthUser?>.empty();

  @override
  Future<void> signInAnonymously() async {}

  @override
  Future<void> signOut() async {}
}

bool _looksLikeKeychainEntitlementError(final Object error) {
  if (error is FirebaseAuthException && error.code == 'keychain-error') {
    return true;
  }
  final String message = error.toString().toLowerCase();
  return message.contains('-34018') ||
      message.contains('secitemadd') ||
      message.contains('keychain') ||
      message.contains('nslocalizedfailurereasonerrorkey') ||
      message.contains('required entitlement');
}
