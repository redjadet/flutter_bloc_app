import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/data/wallet_user_profile_mapper.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/nft_metadata.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/wallet_user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WalletUserProfileMapper', () {
    test('defaultFirestoreMap has expected keys and default values', () {
      final map = WalletUserProfileMapper.defaultFirestoreMap();
      expect(map[WalletUserProfileFields.balanceOffChain], 0.0);
      expect(map[WalletUserProfileFields.balanceOnChain], 0.0);
      expect(map[WalletUserProfileFields.rewards], 0.0);
      expect(map[WalletUserProfileFields.lastClaim], isNull);
      expect(map[WalletUserProfileFields.nfts], isEmpty);
    });

    test('toFirestore includes profile values', () {
      final lastClaim = DateTime(2025, 1, 15);
      const profile = WalletUserProfile(
        balanceOffChain: 10.0,
        balanceOnChain: 20.0,
        rewards: 5.0,
        lastClaim: null,
        nfts: [
          NftMetadata(
            tokenId: '1',
            contractAddress: '0xabc',
            name: 'NFT',
            imageUrl: 'https://example.com/img.png',
          ),
        ],
      );
      final withLastClaim = WalletUserProfile(
        balanceOffChain: profile.balanceOffChain,
        balanceOnChain: profile.balanceOnChain,
        rewards: profile.rewards,
        lastClaim: lastClaim,
        nfts: profile.nfts,
      );
      final map = WalletUserProfileMapper.toFirestore(withLastClaim);
      expect(map[WalletUserProfileFields.balanceOffChain], 10.0);
      expect(map[WalletUserProfileFields.balanceOnChain], 20.0);
      expect(map[WalletUserProfileFields.rewards], 5.0);
      expect(map[WalletUserProfileFields.lastClaim], isA<Timestamp>());
      final nftsList = map[WalletUserProfileFields.nfts] as List<Object?>;
      expect(nftsList, hasLength(1));
      final nftMap = nftsList.first as Map<String, Object?>;
      expect(nftMap[NftMetadataFields.tokenId], '1');
      expect(nftMap[NftMetadataFields.name], 'NFT');
      expect(nftMap[NftMetadataFields.imageUrl], 'https://example.com/img.png');
    });

    test('fromFirestore returns null for null data', () {
      expect(WalletUserProfileMapper.fromFirestore(null), isNull);
    });

    test('fromFirestore parses default-shaped map', () {
      final data = <String, dynamic>{
        WalletUserProfileFields.balanceOffChain: 0.0,
        WalletUserProfileFields.balanceOnChain: 0.0,
        WalletUserProfileFields.rewards: 0.0,
        WalletUserProfileFields.lastClaim: null,
        WalletUserProfileFields.nfts: <Map<String, dynamic>>[],
      };
      final profile = WalletUserProfileMapper.fromFirestore(data);
      expect(profile, isNotNull);
      expect(profile!.balanceOffChain, 0.0);
      expect(profile.balanceOnChain, 0.0);
      expect(profile.rewards, 0.0);
      expect(profile.lastClaim, isNull);
      expect(profile.nfts, isEmpty);
    });

    test('fromFirestore round-trips with toFirestore', () {
      const profile = WalletUserProfile(
        balanceOffChain: 1.5,
        balanceOnChain: 2.5,
        rewards: 0.5,
        nfts: [
          NftMetadata(
            tokenId: '42',
            contractAddress: '0x1234567890123456789012345678901234567890',
            name: 'Round Trip NFT',
          ),
        ],
      );
      final map = WalletUserProfileMapper.toFirestore(profile);
      final mapWithTimestamp = <String, dynamic>{
        ...map,
        WalletUserProfileFields.lastClaim: profile.lastClaim != null
            ? Timestamp.fromDate(profile.lastClaim!)
            : null,
      };
      final restored = WalletUserProfileMapper.fromFirestore(
        Map<String, dynamic>.from(mapWithTimestamp),
      );
      expect(restored, isNotNull);
      expect(restored!.balanceOffChain, profile.balanceOffChain);
      expect(restored.balanceOnChain, profile.balanceOnChain);
      expect(restored.rewards, profile.rewards);
      expect(restored.nfts.length, profile.nfts.length);
      expect(restored.nfts.first.tokenId, profile.nfts.first.tokenId);
      expect(restored.nfts.first.name, profile.nfts.first.name);
    });
  });
}
