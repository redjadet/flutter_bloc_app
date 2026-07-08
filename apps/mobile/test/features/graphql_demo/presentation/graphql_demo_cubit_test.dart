import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_data_source.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/cubit/graphql_demo_cubit.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/cubit/graphql_demo_state.dart';
import 'package:design_system/design_system.dart';
import 'package:utilities/utilities.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubGraphqlDemoRepository implements GraphqlDemoRepository {
  const _StubGraphqlDemoRepository({this.exception});

  final Exception? exception;

  @override
  GraphqlDataSource get lastSource => GraphqlDataSource.unknown;

  @override
  Future<List<GraphqlContinent>> fetchContinents() async {
    final Exception? error = exception;
    if (error != null) {
      throw error;
    }
    return const <GraphqlContinent>[];
  }

  @override
  Future<List<GraphqlCountry>> fetchCountries({String? continentCode}) async {
    final Exception? error = exception;
    if (error != null) {
      throw error;
    }
    return const <GraphqlCountry>[];
  }
}

void main() {
  group('GraphqlDemoCubit', () {
    blocTest<GraphqlDemoCubit, GraphqlDemoState>(
      'emits [loading, success] when loadInitial succeeds',
      build: () => GraphqlDemoCubit(repository: _StubGraphqlDemoRepository()),
      act: (cubit) => cubit.loadInitial(),
      expect: () => const <GraphqlDemoState>[
        GraphqlDemoState(status: ViewStatus.loading),
        GraphqlDemoState(
          status: ViewStatus.success,
          continents: <GraphqlContinent>[],
          countries: <GraphqlCountry>[],
        ),
      ],
    );

    blocTest<GraphqlDemoCubit, GraphqlDemoState>(
      'emits [loading, error] when loadInitial throws GraphqlDemoException',
      build: () => GraphqlDemoCubit(
        repository: _StubGraphqlDemoRepository(
          exception: GraphqlDemoException('error'),
        ),
      ),
      act: (cubit) => cubit.loadInitial(),
      expect: () => <dynamic>[
        const GraphqlDemoState(status: ViewStatus.loading),
        isA<GraphqlDemoState>()
            .having((s) => s.status, 'status', ViewStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', 'error')
            .having(
              (s) => s.errorType,
              'errorType',
              GraphqlDemoErrorType.unknown,
            )
            .having((s) => s.lastError, 'lastError', isA<UnknownError>()),
      ],
    );

    blocTest<GraphqlDemoCubit, GraphqlDemoState>(
      'emits [loading, success] when selectContinent succeeds',
      build: () => GraphqlDemoCubit(repository: _StubGraphqlDemoRepository()),
      act: (cubit) => cubit.selectContinent('AF'),
      expect: () => const <GraphqlDemoState>[
        GraphqlDemoState(status: ViewStatus.loading, activeContinentCode: 'AF'),
        GraphqlDemoState(
          status: ViewStatus.success,
          countries: <GraphqlCountry>[],
          activeContinentCode: 'AF',
        ),
      ],
    );

    blocTest<GraphqlDemoCubit, GraphqlDemoState>(
      'emits [loading, error] when selectContinent throws GraphqlDemoException',
      build: () => GraphqlDemoCubit(
        repository: _StubGraphqlDemoRepository(
          exception: GraphqlDemoException('error'),
        ),
      ),
      act: (cubit) => cubit.selectContinent('AF'),
      expect: () => <dynamic>[
        const GraphqlDemoState(
          status: ViewStatus.loading,
          activeContinentCode: 'AF',
        ),
        isA<GraphqlDemoState>()
            .having((s) => s.status, 'status', ViewStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', 'error')
            .having(
              (s) => s.errorType,
              'errorType',
              GraphqlDemoErrorType.unknown,
            )
            .having((s) => s.activeContinentCode, 'activeContinentCode', 'AF')
            .having((s) => s.lastError, 'lastError', isA<UnknownError>()),
      ],
    );

    blocTest<GraphqlDemoCubit, GraphqlDemoState>(
      'maps network GraphqlDemoException to retryable NetworkError',
      build: () => GraphqlDemoCubit(
        repository: _StubGraphqlDemoRepository(
          exception: GraphqlDemoException(
            'offline',
            type: GraphqlDemoErrorType.network,
          ),
        ),
      ),
      act: (cubit) => cubit.loadInitial(),
      verify: (cubit) {
        final AppError? error = cubit.state.lastError;
        expect(error, isA<NetworkError>());
        expect(error!.isRetryable, isTrue);
      },
    );
  });
}
