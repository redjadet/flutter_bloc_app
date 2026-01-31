import 'package:equatable/equatable.dart';

/// Immutable metadata for an NFT in the user profile.
///
/// Domain model; serialization to/from Firestore is done in the data layer.
class NftMetadata extends Equatable {
  const NftMetadata({
    required this.tokenId,
    required this.contractAddress,
    required this.name,
    this.imageUrl,
  });

  final String tokenId;
  final String contractAddress;
  final String name;
  final String? imageUrl;

  @override
  List<Object?> get props => [tokenId, contractAddress, name, imageUrl];
}
