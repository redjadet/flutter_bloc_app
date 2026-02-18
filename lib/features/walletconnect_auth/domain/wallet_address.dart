import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_address.freezed.dart';

/// Immutable value object representing a wallet address.
///
/// Wallet addresses are Ethereum-style addresses (0x followed by 40 hex characters).
@freezed
abstract class WalletAddress with _$WalletAddress {
  const factory WalletAddress(final String value) = _WalletAddress;

  const WalletAddress._();

  /// Validates that the address is a valid Ethereum address format.
  bool get isValid {
    if (value.isEmpty) return false;
    if (!value.startsWith('0x')) return false;
    if (value.length != 42) return false;
    final String hexPart = value.substring(2);
    return RegExp(r'^[0-9a-fA-F]+$').hasMatch(hexPart);
  }

  /// Returns a truncated version of the address for display.
  String get truncated {
    if (value.length <= 10) return value;
    return '${value.substring(0, 6)}...${value.substring(value.length - 4)}';
  }

  @override
  String toString() => value;
}
