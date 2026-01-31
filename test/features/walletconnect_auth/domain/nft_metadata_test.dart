import 'package:flutter_bloc_app/features/walletconnect_auth/domain/nft_metadata.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NftMetadata', () {
    test('creates with required fields', () {
      const nft = NftMetadata(
        tokenId: '1',
        contractAddress: '0x1234567890123456789012345678901234567890',
        name: 'Test NFT',
      );
      expect(nft.tokenId, '1');
      expect(nft.contractAddress, '0x1234567890123456789012345678901234567890');
      expect(nft.name, 'Test NFT');
      expect(nft.imageUrl, isNull);
    });

    test('creates with optional imageUrl', () {
      const nft = NftMetadata(
        tokenId: '2',
        contractAddress: '0xabc',
        name: 'NFT with image',
        imageUrl: 'https://example.com/nft.png',
      );
      expect(nft.imageUrl, 'https://example.com/nft.png');
    });

    test('equality works correctly', () {
      const nft1 = NftMetadata(
        tokenId: '1',
        contractAddress: '0xabc',
        name: 'Same',
      );
      const nft2 = NftMetadata(
        tokenId: '1',
        contractAddress: '0xabc',
        name: 'Same',
      );
      const nft3 = NftMetadata(
        tokenId: '2',
        contractAddress: '0xabc',
        name: 'Same',
      );
      expect(nft1, equals(nft2));
      expect(nft1, isNot(equals(nft3)));
    });
  });
}
