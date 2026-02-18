import 'package:flutter_bloc_app/features/walletconnect_auth/domain/nft_metadata.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_user_profile.freezed.dart';

/// Immutable user profile stored at Firestore `users/{walletAddress}`.
///
/// Holds balance (off-chain + on-chain), rewards, lastClaim, and NFTs metadata.
/// Domain model; serialization to/from Firestore is done in the data layer.
@freezed
abstract class WalletUserProfile with _$WalletUserProfile {
  const factory WalletUserProfile({
    @Default(0.0) final double balanceOffChain,
    @Default(0.0) final double balanceOnChain,
    @Default(0.0) final double rewards,
    final DateTime? lastClaim,
    @Default(<NftMetadata>[]) final List<NftMetadata> nfts,
  }) = _WalletUserProfile;
}
