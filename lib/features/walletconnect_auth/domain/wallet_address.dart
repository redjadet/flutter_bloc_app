import 'package:equatable/equatable.dart';

/// Immutable value object representing a wallet address.
///
/// Wallet addresses are Ethereum-style addresses (0x followed by 40 hex characters).
class WalletAddress extends Equatable {
  const WalletAddress(this.value);

  /// The wallet address string (e.g., "0x1234...5678").
  final String value;

  /// Validates that the address is a valid Ethereum address format.
  bool get isValid {
    if (value.isEmpty) return false;
    if (!value.startsWith('0x')) return false;
    if (value.length != 42) return false; // 0x + 40 hex chars
    final hexPart = value.substring(2);
    return RegExp(r'^[0-9a-fA-F]+$').hasMatch(hexPart);
  }

  /// Returns a truncated version of the address for display.
  /// Format: "0x1234...5678"
  String get truncated {
    if (value.length <= 10) return value;
    return '${value.substring(0, 6)}...${value.substring(value.length - 4)}';
  }

  @override
  List<Object> get props => [value];

  @override
  String toString() => value;
}
