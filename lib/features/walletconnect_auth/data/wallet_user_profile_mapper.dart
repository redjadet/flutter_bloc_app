import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/nft_metadata.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/wallet_user_profile.dart';

/// Firestore field names for [WalletUserProfile] (stored in same doc as linkage at `users/{uid}`).
abstract class WalletUserProfileFields {
  static const String balanceOffChain = 'balanceOffChain';
  static const String balanceOnChain = 'balanceOnChain';
  static const String rewards = 'rewards';
  static const String lastClaim = 'lastClaim';
  static const String nfts = 'nfts';
  static const String updatedAt = 'updatedAt';
}

/// NFT map keys in Firestore.
abstract class NftMetadataFields {
  static const String tokenId = 'tokenId';
  static const String contractAddress = 'contractAddress';
  static const String name = 'name';
  static const String imageUrl = 'imageUrl';
}

/// Maps [WalletUserProfile] and [NftMetadata] to/from Firestore maps.
class WalletUserProfileMapper {
  WalletUserProfileMapper._();

  /// Converts [WalletUserProfile] to a Firestore-serializable map.
  /// The updatedAt field is not included; set separately with [FieldValue.serverTimestamp()].
  static Map<String, Object?> toFirestore(final WalletUserProfile profile) {
    return <String, Object?>{
      WalletUserProfileFields.balanceOffChain: profile.balanceOffChain,
      WalletUserProfileFields.balanceOnChain: profile.balanceOnChain,
      WalletUserProfileFields.rewards: profile.rewards,
      WalletUserProfileFields.lastClaim: switch (profile.lastClaim) {
        final d? => Timestamp.fromDate(d),
        _ => null,
      },
      WalletUserProfileFields.nfts: profile.nfts.map(_nftToMap).toList(),
    };
  }

  /// Builds default profile map for initial upsert (zeros, null lastClaim, empty nfts).
  static Map<String, Object?> defaultFirestoreMap() =>
      toFirestore(const WalletUserProfile());

  /// Parses Firestore document data into [WalletUserProfile].
  /// Returns null if [data] is null or invalid.
  static WalletUserProfile? fromFirestore(final Map<String, dynamic>? data) {
    if (data == null) return null;
    try {
      final lastClaimTimestamp = data[WalletUserProfileFields.lastClaim];
      final DateTime? lastClaim = lastClaimTimestamp is Timestamp
          ? lastClaimTimestamp.toDate()
          : null;

      final nftsRaw = data[WalletUserProfileFields.nfts];
      final List<NftMetadata> nftsList = nftsRaw is List
          ? nftsRaw
                .map(
                  (final e) => _nftFromMap(
                    e is Map ? Map<String, dynamic>.from(e) : null,
                  ),
                )
                .whereType<NftMetadata>()
                .toList()
          : <NftMetadata>[];

      final balanceOffChain = _toDouble(
        data[WalletUserProfileFields.balanceOffChain],
        0,
      );
      final balanceOnChain = _toDouble(
        data[WalletUserProfileFields.balanceOnChain],
        0,
      );
      final rewards = _toDouble(data[WalletUserProfileFields.rewards], 0);

      return WalletUserProfile(
        balanceOffChain: balanceOffChain,
        balanceOnChain: balanceOnChain,
        rewards: rewards,
        lastClaim: lastClaim,
        nfts: nftsList,
      );
    } on Object {
      return null;
    }
  }

  static Map<String, Object?> _nftToMap(final NftMetadata nft) {
    return <String, Object?>{
      NftMetadataFields.tokenId: nft.tokenId,
      NftMetadataFields.contractAddress: nft.contractAddress,
      NftMetadataFields.name: nft.name,
      NftMetadataFields.imageUrl: nft.imageUrl,
    };
  }

  static NftMetadata? _nftFromMap(final Map<String, dynamic>? map) {
    if (map == null) return null;
    final tokenId = map[NftMetadataFields.tokenId] as String?;
    final contractAddress = map[NftMetadataFields.contractAddress] as String?;
    final name = map[NftMetadataFields.name] as String?;
    if (tokenId == null || contractAddress == null || name == null) {
      return null;
    }
    return NftMetadata(
      tokenId: tokenId,
      contractAddress: contractAddress,
      name: name,
      imageUrl: map[NftMetadataFields.imageUrl] as String?,
    );
  }

  static double _toDouble(final Object? value, final double fallback) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }
}
