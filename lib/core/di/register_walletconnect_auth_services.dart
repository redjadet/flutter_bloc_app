import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/data/walletconnect_auth_repository_impl.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/data/walletconnect_service.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/wallet_address.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/walletconnect_auth_repository.dart';

/// Registers WalletConnect Auth services.
void registerWalletConnectAuthServices() {
  registerLazySingletonIfAbsent<WalletConnectService>(
    () => WalletConnectService(),
    dispose: (final service) => service.dispose(),
  );

  registerLazySingletonIfAbsent<WalletConnectAuthRepository>(
    () {
      // Try to get Firebase services if available
      try {
        final app = Firebase.app();
        final auth = FirebaseAuth.instanceFor(app: app);
        final firestore = FirebaseFirestore.instanceFor(app: app);
        return WalletConnectAuthRepositoryImpl(
          walletConnectService: getIt<WalletConnectService>(),
          firebaseAuth: auth,
          firestore: firestore,
        );
      } on Exception {
        // If Firebase is not available, create a mock implementation
        // This allows the feature to work in tests or when Firebase is not initialized
        return _createMockWalletConnectAuthRepository(
          walletConnectService: getIt<WalletConnectService>(),
        );
      }
    },
  );
}

/// Creates a mock repository for testing or when Firebase is unavailable.
WalletConnectAuthRepository _createMockWalletConnectAuthRepository({
  required final WalletConnectService walletConnectService,
}) => _MockWalletConnectAuthRepository(walletConnectService: walletConnectService);

/// Mock implementation for testing.
class _MockWalletConnectAuthRepository implements WalletConnectAuthRepository {
  _MockWalletConnectAuthRepository({
    required final WalletConnectService walletConnectService,
  }) : _walletConnectService = walletConnectService;

  final WalletConnectService _walletConnectService;
  WalletAddress? _linkedAddress;

  @override
  Future<WalletAddress> connectWallet() async {
    return _walletConnectService.connect();
  }

  @override
  Future<void> disconnectWallet() async {
    await _walletConnectService.disconnect();
    _linkedAddress = null;
  }

  @override
  Future<WalletAddress?> getLinkedWalletAddress() async => _linkedAddress;

  @override
  Future<void> linkWalletToFirebaseUser(final String walletAddress) async {
    final address = WalletAddress(walletAddress);
    if (!address.isValid) {
      throw WalletConnectException(
        'Invalid wallet address format: $walletAddress',
      );
    }

    _linkedAddress = address;
  }
}
