import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/search/domain/search_repository.dart';
import 'package:flutter_bloc_app/features/search/domain/search_result.dart';
import 'package:flutter_bloc_app/features/search/presentation/search_cubit.dart';
import 'package:flutter_bloc_app/features/search/presentation/search_state.dart';

import '../../../test_helpers.dart';

class _StubSearchRepository extends SearchRepository {
  _StubSearchRepository({required this.onSearch});

  final Future<List<SearchResult>> Function(String query) onSearch;

  @override
  Future<List<SearchResult>> search(final String query) => onSearch(query);
}

void main() {
  group('SearchCubit', () {
    late FakeTimerService timerService;
    late List<String> capturedQueries;

    setUp(() {
      timerService = FakeTimerService();
      capturedQueries = <String>[];
    });

    SearchCubit buildCubit(
      Future<List<SearchResult>> Function(String query) onSearch,
    ) => SearchCubit(
      repository: _StubSearchRepository(
        onSearch: (final query) async {
          capturedQueries.add(query);
          return onSearch(query);
        },
      ),
      timerService: timerService,
      debounceDuration: const Duration(milliseconds: 300),
    );

    blocTest<SearchCubit, SearchState>(
      'debounces rapid queries and only searches with the latest value',
      build: () => buildCubit(
        (final query) async => <SearchResult>[
          SearchResult(id: query, imageUrl: 'https://example.com/$query.png'),
        ],
      ),
      act: (final cubit) {
        cubit.search('d');
        cubit.search('do');
        cubit.search('dog');
        timerService.elapse(const Duration(milliseconds: 300));
      },
      expect: () => <dynamic>[
        const SearchState(query: 'd'),
        const SearchState(query: 'do'),
        const SearchState(query: 'dog'),
        isA<SearchState>()
            .having(
              (final state) => state.status,
              'status',
              SearchStatus.loading,
            )
            .having((final state) => state.query, 'query', 'dog'),
        isA<SearchState>()
            .having(
              (final state) => state.status,
              'status',
              SearchStatus.success,
            )
            .having((final state) => state.query, 'query', 'dog')
            .having(
              (final state) => state.results.single.id,
              'result id',
              'dog',
            ),
      ],
      verify: (_) => expect(capturedQueries, equals(<String>['dog'])),
    );

    blocTest<SearchCubit, SearchState>(
      'clearSearch cancels pending searches and resets state',
      build: () => buildCubit(
        (final query) async => <SearchResult>[
          SearchResult(id: query, imageUrl: 'https://example.com/$query.png'),
        ],
      ),
      act: (final cubit) {
        cubit.search('dogs');
        cubit.clearSearch();
        timerService.elapse(const Duration(milliseconds: 300));
      },
      expect: () => <SearchState>[
        const SearchState(query: 'dogs'),
        const SearchState(),
      ],
      verify: (_) => expect(capturedQueries, isEmpty),
    );

    blocTest<SearchCubit, SearchState>(
      'emits an error state when the repository throws',
      build: () => buildCubit((final _) async {
        throw Exception('failed');
      }),
      act: (final cubit) {
        cubit.search('error');
        timerService.elapse(const Duration(milliseconds: 300));
      },
      expect: () => <dynamic>[
        const SearchState(query: 'error'),
        isA<SearchState>()
            .having(
              (final state) => state.status,
              'status',
              SearchStatus.loading,
            )
            .having((final state) => state.query, 'query', 'error'),
        isA<SearchState>()
            .having((final state) => state.status, 'status', SearchStatus.error)
            .having((final state) => state.query, 'query', 'error')
            .having((final state) => state.error, 'error', isA<Exception>()),
      ],
    );
  });
}
