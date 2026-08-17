import 'package:freezed_annotation/freezed_annotation.dart';

part 'nft_metadata.freezed.dart';

/// Immutable metadata for an NFT in the user profile.
///
/// Domain model; serialization to/from Firestore is done in the data layer.
@freezed
abstract class NftMetadata with _$NftMetadata {
  const factory NftMetadata({
    required String tokenId,
    required String contractAddress,
    required String name,
    String? imageUrl,
  }) = _NftMetadata;
}
