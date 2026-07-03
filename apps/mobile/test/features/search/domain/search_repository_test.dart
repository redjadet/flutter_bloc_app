import 'package:flutter_bloc_app/features/search/domain/search_repository.dart';
import 'package:flutter_bloc_app/features/search/domain/search_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SearchRepository', () {
    test('call delegates to search method', () async {
      final repository = _TestSearchRepository();
      final results = await repository.call('test query');
      expect(results, hasLength(1));
      expect(results.first.id, 'result-1');
    });

    test('search returns list of results', () async {
      final repository = _TestSearchRepository();
      final results = await repository.search('test');
      expect(results, isA<List<SearchResult>>());
      expect(results, hasLength(1));
    });
  });
}

class _TestSearchRepository extends SearchRepository {
  @override
  Future<List<SearchResult>> search(final String query) async {
    return [
      SearchResult(
        id: 'result-1',
        imageUrl: 'https://example.com/image.jpg',
        title: 'Test Result',
        description: 'Test description',
      ),
    ];
  }
}
