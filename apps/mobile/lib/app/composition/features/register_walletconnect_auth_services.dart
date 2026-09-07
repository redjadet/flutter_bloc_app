import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/data/walletconnect_auth_repository_impl.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/data/walletconnect_service.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/wallet_address.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/wallet_user_profile.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/walletconnect_auth_repository.dart';

/// Registers WalletConnect Auth services.
void registerWalletConnectAuthServices() {
  registerLazySingletonIfAbsent<WalletConnectService>(
    () => WalletConnectService(),
    dispose: (service) => service.dispose(),
  );

  registerLazySingletonIfAbsent<WalletConnectAuthRepository>(() {
    // Web release skips Firebase bootstrap, but the JS SDK can still load.
    // Firebase.app() then throws a raw JS Error (not a Dart Exception). The
    // previous `on Exception` miss left that Error uncaught, cleared the
    // HTML splash after WebLaunchSplash, and left a blank Flutter view on
    // GitHub Pages — looking like a stuck load.
    try {
      if (Firebase.apps.isEmpty) {
        return _createMockWalletConnectAuthRepository(
          walletConnectService: getIt<WalletConnectService>(),
        );
      }
      final app = Firebase.app();
      final auth = FirebaseAuth.instanceFor(app: app);
      final firestore = FirebaseFirestore.instanceFor(app: app);
      return WalletConnectAuthRepositoryImpl(
        walletConnectService: getIt<WalletConnectService>(),
        firebaseAuth: auth,
        firestore: firestore,
      );
    } on Object {
      return _createMockWalletConnectAuthRepository(
        walletConnectService: getIt<WalletConnectService>(),
      );
    }
  });
}

/// Creates a mock repository for testing or when Firebase is unavailable.
WalletConnectAuthRepository _createMockWalletConnectAuthRepository({
  required WalletConnectService walletConnectService,
}) => _MockWalletConnectAuthRepository(
  walletConnectService: walletConnectService,
);

/// Mock implementation for testing.
class _MockWalletConnectAuthRepository implements WalletConnectAuthRepository {
  new({required this._walletConnectService});

  final WalletConnectService _walletConnectService;
  WalletAddress? _linkedAddress;

  @override
  Future<WalletAddress> connectWallet() async {
    return await _walletConnectService.connect();
  }

  @override
  Future<void> disconnectWallet() async {
    await _walletConnectService.disconnect();
    _linkedAddress = null;
  }

  @override
  Future<WalletAddress?> getLinkedWalletAddress() async => _linkedAddress;

  @override
  Future<void> linkWalletToFirebaseUser(String walletAddress) async {
    final address = WalletAddress(walletAddress);
    if (!address.isValid) {
      throw WalletConnectException(
        'Invalid wallet address format: $walletAddress',
      );
    }

    _linkedAddress = address;
    await upsertWalletUserProfile(walletAddress);
  }

  @override
  Future<void> upsertWalletUserProfile(
    String walletAddress, {
    WalletUserProfile? profile,
  }) async {
    // No-op for mock
  }

  @override
  Future<WalletUserProfile?> getWalletUserProfile(String walletAddress) async =>
      null;
}
