import 'package:flutter_bloc_app/features/walletconnect_auth/domain/nft_metadata.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/wallet_user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WalletUserProfile', () {
    test('default constructor has zero balances and empty nfts', () {
      const profile = WalletUserProfile();
      expect(profile.balanceOffChain, 0.0);
      expect(profile.balanceOnChain, 0.0);
      expect(profile.rewards, 0.0);
      expect(profile.lastClaim, isNull);
      expect(profile.nfts, isEmpty);
    });

    test('creates with custom values', () {
      final lastClaim = DateTime(2025, 1, 1);
      const nfts = <NftMetadata>[
        NftMetadata(tokenId: '1', contractAddress: '0xabc', name: 'NFT One'),
      ];
      final profile = WalletUserProfile(
        balanceOffChain: 10.5,
        balanceOnChain: 100.0,
        rewards: 5.0,
        lastClaim: lastClaim,
        nfts: nfts,
      );
      expect(profile.balanceOffChain, 10.5);
      expect(profile.balanceOnChain, 100.0);
      expect(profile.rewards, 5.0);
      expect(profile.lastClaim, lastClaim);
      expect(profile.nfts, hasLength(1));
      expect(profile.nfts.first.name, 'NFT One');
    });

    test('equality works correctly', () {
      const profile1 = WalletUserProfile(
        balanceOffChain: 1.0,
        balanceOnChain: 2.0,
      );
      const profile2 = WalletUserProfile(
        balanceOffChain: 1.0,
        balanceOnChain: 2.0,
      );
      const profile3 = WalletUserProfile(balanceOffChain: 3.0);
      expect(profile1, equals(profile2));
      expect(profile1, isNot(equals(profile3)));
    });
  });
}
