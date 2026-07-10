import 'package:flutter_bloc_app/app/composition/features/register_walletconnect_auth_services.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/data/walletconnect_service.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/walletconnect_auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockWalletConnectService extends Mock implements WalletConnectService {}

void main() {
  setUp(() async {
    await getIt.reset(dispose: true);
  });

  tearDown(() async {
    await getIt.reset(dispose: true);
  });

  group('registerWalletConnectAuthServices', () {
    test('registers WalletConnectService and WalletConnectAuthRepository', () {
      final service = _MockWalletConnectService();
      getIt.registerSingleton<WalletConnectService>(service);

      registerWalletConnectAuthServices();

      expect(getIt.isRegistered<WalletConnectService>(), isTrue);
      expect(getIt.isRegistered<WalletConnectAuthRepository>(), isTrue);
    });

    test('uses mock repository when Firebase is unavailable', () async {
      final service = _MockWalletConnectService();
      getIt.registerSingleton<WalletConnectService>(service);

      registerWalletConnectAuthServices();

      final repo = getIt<WalletConnectAuthRepository>();

      // The mock repo validates wallet address format.
      Object? caught;
      try {
        await repo.linkWalletToFirebaseUser('not-a-wallet-address');
      } on Object catch (error) {
        caught = error;
      }

      expect(caught, isNotNull);
    });
  });
}
