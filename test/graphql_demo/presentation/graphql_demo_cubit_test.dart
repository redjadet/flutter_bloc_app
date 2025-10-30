import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/graphql_demo_cubit.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/graphql_demo_state.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GraphqlDemoCubit', () {
    late FakeGraphqlDemoRepository repository;

    setUp(() {
      repository = FakeGraphqlDemoRepository();
    });

    GraphqlDemoCubit createCubit() => GraphqlDemoCubit(repository: repository);

    blocTest<GraphqlDemoCubit, GraphqlDemoState>(
      'emits success with continents and countries on loadInitial',
      build: createCubit,
      act: (cubit) => AppLogger.silenceAsync(() => cubit.loadInitial()),
      expect: () => [
        const GraphqlDemoState(status: ViewStatus.loading),
        predicate<GraphqlDemoState>((state) {
          return state.status == ViewStatus.success &&
              state.continents.length == repository.continents.length &&
              state.countries.length ==
                  repository.countriesByCode[null]!.length;
        }),
      ],
    );

    blocTest<GraphqlDemoCubit, GraphqlDemoState>(
      'selectContinent fetches filtered countries',
      build: createCubit,
      seed: () => GraphqlDemoState(
        status: ViewStatus.success,
        continents: repository.continents,
        countries: repository.countriesByCode[null]!,
      ),
      act: (cubit) => cubit.selectContinent('EU'),
      expect: () => [
        GraphqlDemoState(
          status: ViewStatus.loading,
          continents: repository.continents,
          countries: repository.countriesByCode[null]!,
          activeContinentCode: 'EU',
        ),
        GraphqlDemoState(
          status: ViewStatus.success,
          continents: repository.continents,
          countries: repository.countriesByCode['EU']!,
          activeContinentCode: 'EU',
        ),
      ],
    );

    blocTest<GraphqlDemoCubit, GraphqlDemoState>(
      'refresh reloads current continent',
      build: createCubit,
      seed: () => GraphqlDemoState(
        status: ViewStatus.success,
        continents: repository.continents,
        countries: repository.countriesByCode['EU']!,
        activeContinentCode: 'EU',
      ),
      act: (cubit) => cubit.refresh(),
      expect: () => [
        GraphqlDemoState(
          status: ViewStatus.loading,
          continents: repository.continents,
          countries: repository.countriesByCode['EU']!,
          activeContinentCode: 'EU',
        ),
        GraphqlDemoState(
          status: ViewStatus.success,
          continents: repository.continents,
          countries: repository.countriesByCode['EU']!,
          activeContinentCode: 'EU',
        ),
      ],
    );

    blocTest<GraphqlDemoCubit, GraphqlDemoState>(
      'selectContinent ignores redundant selections',
      build: createCubit,
      seed: () => GraphqlDemoState(
        status: ViewStatus.success,
        continents: repository.continents,
        countries: repository.countriesByCode['EU']!,
        activeContinentCode: 'EU',
      ),
      act: (cubit) => cubit.selectContinent('EU'),
      expect: () => const <GraphqlDemoState>[],
    );

    blocTest<GraphqlDemoCubit, GraphqlDemoState>(
      'emits error state when repository throws',
      build: () {
        repository.shouldThrow = true;
        return createCubit();
      },
      act: (cubit) => AppLogger.silenceAsync(() => cubit.loadInitial()),
      expect: () => [
        const GraphqlDemoState(status: ViewStatus.loading),
        const GraphqlDemoState(
          status: ViewStatus.error,
          errorMessage: 'Load failed',
          errorType: GraphqlDemoErrorType.unknown,
        ),
      ],
    );

    blocTest<GraphqlDemoCubit, GraphqlDemoState>(
      'emits generic error when repository throws unexpected exception',
      build: () {
        repository.shouldThrowGeneric = true;
        return createCubit();
      },
      act: (cubit) => AppLogger.silenceAsync(() => cubit.loadInitial()),
      expect: () => const <GraphqlDemoState>[
        GraphqlDemoState(status: ViewStatus.loading),
        GraphqlDemoState(
          status: ViewStatus.error,
          errorMessage: null,
          errorType: GraphqlDemoErrorType.unknown,
        ),
      ],
    );

    blocTest<GraphqlDemoCubit, GraphqlDemoState>(
      'selectContinent surfaces GraphqlDemoException',
      build: () => createCubit(),
      seed: () => GraphqlDemoState(
        status: ViewStatus.success,
        continents: repository.continents,
        countries: repository.countriesByCode[null]!,
      ),
      act: (cubit) {
        repository.shouldThrow = true;
        return AppLogger.silenceAsync(() => cubit.selectContinent('EU'));
      },
      expect: () => [
        GraphqlDemoState(
          status: ViewStatus.loading,
          continents: repository.continents,
          countries: repository.countriesByCode[null]!,
          activeContinentCode: 'EU',
        ),
        GraphqlDemoState(
          status: ViewStatus.error,
          continents: repository.continents,
          countries: repository.countriesByCode[null]!,
          activeContinentCode: 'EU',
          errorMessage: 'Load failed',
          errorType: GraphqlDemoErrorType.unknown,
        ),
      ],
    );

    blocTest<GraphqlDemoCubit, GraphqlDemoState>(
      'selectContinent surfaces unknown exception as generic error',
      build: () => createCubit(),
      seed: () => GraphqlDemoState(
        status: ViewStatus.success,
        continents: repository.continents,
        countries: repository.countriesByCode[null]!,
      ),
      act: (cubit) {
        repository.shouldThrowGeneric = true;
        return AppLogger.silenceAsync(() => cubit.selectContinent('EU'));
      },
      expect: () => [
        GraphqlDemoState(
          status: ViewStatus.loading,
          continents: repository.continents,
          countries: repository.countriesByCode[null]!,
          activeContinentCode: 'EU',
        ),
        GraphqlDemoState(
          status: ViewStatus.error,
          continents: repository.continents,
          countries: repository.countriesByCode[null]!,
          activeContinentCode: 'EU',
          errorMessage: null,
          errorType: GraphqlDemoErrorType.unknown,
        ),
      ],
    );
  });
}

class FakeGraphqlDemoRepository implements GraphqlDemoRepository {
  FakeGraphqlDemoRepository()
    : continents = <GraphqlContinent>[
        const GraphqlContinent(code: 'EU', name: 'Europe'),
        const GraphqlContinent(code: 'AS', name: 'Asia'),
      ],
      countriesByCode = <String?, List<GraphqlCountry>>{
        null: <GraphqlCountry>[
          GraphqlCountry(
            code: 'DE',
            name: 'Germany',
            capital: 'Berlin',
            currency: 'EUR',
            continent: const GraphqlContinent(code: 'EU', name: 'Europe'),
          ),
          GraphqlCountry(
            code: 'JP',
            name: 'Japan',
            capital: 'Tokyo',
            currency: 'JPY',
            continent: const GraphqlContinent(code: 'AS', name: 'Asia'),
          ),
        ],
        'EU': <GraphqlCountry>[
          GraphqlCountry(
            code: 'DE',
            name: 'Germany',
            capital: 'Berlin',
            currency: 'EUR',
            continent: const GraphqlContinent(code: 'EU', name: 'Europe'),
          ),
        ],
      };

  final List<GraphqlContinent> continents;
  final Map<String?, List<GraphqlCountry>> countriesByCode;
  bool shouldThrow = false;
  bool shouldThrowGeneric = false;

  @override
  Future<List<GraphqlContinent>> fetchContinents() async {
    if (shouldThrow) {
      throw GraphqlDemoException('Load failed');
    }
    if (shouldThrowGeneric) {
      throw Exception('network down');
    }
    return continents;
  }

  @override
  Future<List<GraphqlCountry>> fetchCountries({String? continentCode}) async {
    if (shouldThrow) {
      throw GraphqlDemoException('Load failed');
    }
    if (shouldThrowGeneric) {
      throw Exception('network down');
    }
    return countriesByCode[continentCode] ?? <GraphqlCountry>[];
  }
}
