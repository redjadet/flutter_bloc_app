import 'dart:convert';

import 'package:flutter_bloc_app/features/search/domain/search_repository.dart';
import 'package:flutter_bloc_app/features/search/domain/search_result.dart';

class MockSearchRepository implements SearchRepository {
  static String _decode(final String encoded) =>
      utf8.decode(base64Decode(encoded));

  static final String _imageUrlPrefix = _decode(
    'aHR0cHM6Ly9hcGkuYnVpbGRlci5pby9hcGkvdjEvaW1hZ2UvYXNzZXRzL1RFTVAv',
  );

  static final String _imageUrlSuffix = _decode('P3dpZHRoPTIxNA==');

  @override
  Future<List<SearchResult>> search(final String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    return List.generate(
      12,
      (final index) => SearchResult(
        id: 'dog_$index',
        imageUrl: _resolveImageUrl(index),
      ),
    );
  }

  static const List<String> _imageIds = [
    '5a64da3b7592b850f3d7a5e6a3e049a6ecbf62f8',
    'ddb5900f81c29926fd2e9e20b65bcc0e262cae56',
    'fd75f466253cd11c922be13813ff1f9fc285dc6c',
    'aab51d832a6730fb3ab7b7d57dc80d4a4a828b89',
    '45cd1fa06a6c2510dbefb18647fa2308ed62ea57',
    'ca761c10529de2be8861f3b9f7726a898b0de214',
    '788b4db3f35867548f2535569873c2bd53c1426d',
    '9543387f32b429380181e18386874cf149660c76',
    '1a4d8a1f33b88bba1f51417f7535a682f1cc4924',
    'd2ce5d1ecb5b170c4f22d3306c7105eb7ed00759',
    '40a2b01df8a2d14480c61530b880040d5b98681a',
    'c9e00052f89845fa223cf7819c61ddee5b51e541',
  ];

  static String _resolveImageUrl(final int index) {
    final String imageId = _imageIds[index % _imageIds.length];
    return '$_imageUrlPrefix$imageId$_imageUrlSuffix';
  }

  @override
  Future<List<SearchResult>> call(final String query) => search(query);
}
