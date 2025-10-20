import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/graphql_demo_cubit.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/graphql_demo_state.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/pages/graphql_demo_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

class _StubGraphqlDemoRepository implements GraphqlDemoRepository {
  @override
  Future<List<GraphqlContinent>> fetchContinents() async =>
      const <GraphqlContinent>[];

  @override
  Future<List<GraphqlCountry>> fetchCountries({String? continentCode}) async =>
      const <GraphqlCountry>[];
}

class _TestGraphqlDemoCubit extends GraphqlDemoCubit {
  _TestGraphqlDemoCubit() : super(repository: _StubGraphqlDemoRepository());

  void emitState(GraphqlDemoState state) => emit(state);

  @override
  Future<void> loadInitial() async {}

  @override
  Future<void> refresh() async {}

  @override
  Future<void> selectContinent(
    String? continentCode, {
    bool force = false,
  }) async {}
}

void main() {
  group('GraphqlDemoPage', () {
    late _TestGraphqlDemoCubit cubit;

    setUp(() {
      cubit = _TestGraphqlDemoCubit();
    });

    tearDown(() async {
      await cubit.close();
    });

    Future<void> pumpPage(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<GraphqlDemoCubit>.value(
            value: cubit,
            child: const GraphqlDemoPage(),
          ),
        ),
      );
    }

    testWidgets('renders a loading indicator when state is loading', (
      tester,
    ) async {
      cubit.emitState(
        const GraphqlDemoState(status: GraphqlDemoStatus.loading),
      );

      await pumpPage(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders an error message when state has an error', (
      tester,
    ) async {
      cubit.emitState(
        const GraphqlDemoState(
          status: GraphqlDemoStatus.error,
          errorMessage: 'error',
        ),
      );

      await pumpPage(tester);

      expect(find.text('error'), findsOneWidget);
    });

    testWidgets('renders countries when state is success', (tester) async {
      cubit.emitState(
        const GraphqlDemoState(
          status: GraphqlDemoStatus.success,
          countries: <GraphqlCountry>[
            GraphqlCountry(
              code: 'AD',
              name: 'Andorra',
              continent: GraphqlContinent(code: 'EU', name: 'Europe'),
            ),
          ],
        ),
      );

      await pumpPage(tester);

      expect(find.text('Andorra'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
