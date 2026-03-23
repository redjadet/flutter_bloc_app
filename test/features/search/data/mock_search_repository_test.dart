import 'package:flutter_bloc_app/features/search/data/mock_search_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MockSearchRepository', () {
    test('returns no results for dedicated not-found queries', () async {
      final repository = MockSearchRepository();

      final results = await repository.search('zzzz-not-found-query');

      expect(results, isEmpty);
    });
  });
}
