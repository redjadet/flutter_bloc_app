import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/graphql_demo_cubit.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/graphql_demo_state.dart';

class _StubGraphqlDemoRepository implements GraphqlDemoRepository {
  const _StubGraphqlDemoRepository({this.exception});

  final Exception? exception;

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
        GraphqlDemoState(status: GraphqlDemoStatus.loading),
        GraphqlDemoState(
          status: GraphqlDemoStatus.success,
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
      expect: () => const <GraphqlDemoState>[
        GraphqlDemoState(status: GraphqlDemoStatus.loading),
        GraphqlDemoState(
          status: GraphqlDemoStatus.error,
          errorMessage: 'error',
          errorType: GraphqlDemoErrorType.unknown,
        ),
      ],
    );

    blocTest<GraphqlDemoCubit, GraphqlDemoState>(
      'emits [loading, success] when selectContinent succeeds',
      build: () => GraphqlDemoCubit(repository: _StubGraphqlDemoRepository()),
      act: (cubit) => cubit.selectContinent('AF'),
      expect: () => const <GraphqlDemoState>[
        GraphqlDemoState(
          status: GraphqlDemoStatus.loading,
          activeContinentCode: 'AF',
        ),
        GraphqlDemoState(
          status: GraphqlDemoStatus.success,
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
      expect: () => const <GraphqlDemoState>[
        GraphqlDemoState(
          status: GraphqlDemoStatus.loading,
          activeContinentCode: 'AF',
        ),
        GraphqlDemoState(
          status: GraphqlDemoStatus.error,
          errorMessage: 'error',
          errorType: GraphqlDemoErrorType.unknown,
          activeContinentCode: 'AF',
        ),
      ],
    );
  });
}
