import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/nft_metadata.dart';

/// Immutable user profile stored at Firestore `users/{walletAddress}`.
///
/// Holds balance (off-chain + on-chain), rewards, lastClaim, and NFTs metadata.
/// Domain model; serialization to/from Firestore is done in the data layer.
class WalletUserProfile extends Equatable {
  const WalletUserProfile({
    this.balanceOffChain = 0.0,
    this.balanceOnChain = 0.0,
    this.rewards = 0.0,
    this.lastClaim,
    this.nfts = const <NftMetadata>[],
  });

  final double balanceOffChain;
  final double balanceOnChain;
  final double rewards;
  final DateTime? lastClaim;
  final List<NftMetadata> nfts;

  @override
  List<Object?> get props => [
    balanceOffChain,
    balanceOnChain,
    rewards,
    lastClaim,
    nfts,
  ];
}
