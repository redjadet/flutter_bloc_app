import 'package:flutter_bloc_app/features/walletconnect_auth/domain/wallet_address.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WalletAddress', () {
    test('creates valid address', () {
      const address = WalletAddress(
        '0x1234567890123456789012345678901234567890',
      );
      expect(address.value, '0x1234567890123456789012345678901234567890');
    });

    test('isValid returns true for valid Ethereum address', () {
      const address = WalletAddress(
        '0x1234567890123456789012345678901234567890',
      );
      expect(address.isValid, isTrue);
    });

    test('isValid returns false for empty address', () {
      const address = WalletAddress('');
      expect(address.isValid, isFalse);
    });

    test('isValid returns false for address without 0x prefix', () {
      const address = WalletAddress('1234567890123456789012345678901234567890');
      expect(address.isValid, isFalse);
    });

    test('isValid returns false for address with wrong length', () {
      const address = WalletAddress('0x1234');
      expect(address.isValid, isFalse);
    });

    test('truncated returns full address if short', () {
      const address = WalletAddress('0x1234');
      expect(address.truncated, '0x1234');
    });

    test('truncated returns truncated format for long address', () {
      const address = WalletAddress(
        '0x1234567890123456789012345678901234567890',
      );
      expect(address.truncated, '0x1234...7890');
    });

    test('toString returns the address value', () {
      const address = WalletAddress(
        '0x1234567890123456789012345678901234567890',
      );
      expect(address.toString(), '0x1234567890123456789012345678901234567890');
    });

    test('equality works correctly', () {
      const address1 = WalletAddress(
        '0x1234567890123456789012345678901234567890',
      );
      const address2 = WalletAddress(
        '0x1234567890123456789012345678901234567890',
      );
      const address3 = WalletAddress(
        '0x9876543210987654321098765432109876543210',
      );

      expect(address1, equals(address2));
      expect(address1, isNot(equals(address3)));
    });
  });
}
