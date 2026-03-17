import 'package:flutter_bloc_app/features/walletconnect_auth/data/walletconnect_service.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/wallet_address.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WalletConnectService', () {
    late WalletConnectService service;

    setUp(() {
      service = WalletConnectService();
    });

    tearDown(() {
      service.dispose();
    });

    test('initialize is idempotent', () async {
      await service.initialize();
      await service.initialize();
      expect(service.isConnected, isFalse);
      expect(service.connectedAddress, isNull);
    });

    test('connect returns valid address and sets isConnected', () async {
      await service.initialize();
      final WalletAddress address = await service.connect();
      expect(address.value, '0x1234567890123456789012345678901234567890');
      expect(address.isValid, isTrue);
      expect(service.isConnected, isTrue);
      expect(service.connectedAddress, same(address));
    });

    test('disconnect clears connected state', () async {
      await service.initialize();
      await service.connect();
      expect(service.isConnected, isTrue);
      await service.disconnect();
      expect(service.isConnected, isFalse);
      expect(service.connectedAddress, isNull);
    });

    test('dispose clears state', () async {
      await service.initialize();
      await service.connect();
      service.dispose();
      expect(service.isConnected, isFalse);
      expect(service.connectedAddress, isNull);
    });

    test('connect without explicit initialize still connects', () async {
      final WalletAddress address = await service.connect();
      expect(address.isValid, isTrue);
      expect(service.isConnected, isTrue);
    });
  });
}
