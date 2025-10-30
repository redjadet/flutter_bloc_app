import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/graphql_demo_cubit.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/graphql_demo_state.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/pages/graphql_demo_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('GraphqlDemoPage shows loading indicator before data arrives', (
    WidgetTester tester,
  ) async {
    final _StubGraphqlDemoCubit cubit = _StubGraphqlDemoCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(_wrapWithCubit(cubit));

    cubit.emit(const GraphqlDemoState(status: ViewStatus.loading));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('GraphqlDemoPage shows error view with retry button', (
    WidgetTester tester,
  ) async {
    final _StubGraphqlDemoCubit cubit = _StubGraphqlDemoCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(_wrapWithCubit(cubit));

    cubit.emit(
      const GraphqlDemoState(
        status: ViewStatus.error,
        errorMessage: 'Network down',
        errorType: GraphqlDemoErrorType.network,
      ),
    );
    await tester.pump();

    final AppLocalizationsEn en = AppLocalizationsEn();
    expect(find.text(en.graphqlSampleErrorTitle), findsOneWidget);
    expect(find.text(en.graphqlSampleRetryButton), findsOneWidget);
  });

  testWidgets('GraphqlDemoPage shows empty state when no countries', (
    WidgetTester tester,
  ) async {
    final _StubGraphqlDemoCubit cubit = _StubGraphqlDemoCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(_wrapWithCubit(cubit));

    cubit.emit(
      const GraphqlDemoState(
        status: ViewStatus.success,
        countries: <GraphqlCountry>[],
      ),
    );
    await tester.pump();

    expect(find.text(AppLocalizationsEn().graphqlSampleEmpty), findsOneWidget);
  });

  testWidgets('GraphqlDemoPage renders country cards and filter', (
    WidgetTester tester,
  ) async {
    final _StubGraphqlDemoCubit cubit = _StubGraphqlDemoCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(_wrapWithCubit(cubit));

    cubit.emit(
      GraphqlDemoState(
        status: ViewStatus.success,
        countries: const <GraphqlCountry>[
          GraphqlCountry(
            code: 'TR',
            name: 'Türkiye',
            continent: GraphqlContinent(code: 'EU', name: 'Europe'),
          ),
        ],
        continents: const <GraphqlContinent>[
          GraphqlContinent(code: 'EU', name: 'Europe'),
        ],
        activeContinentCode: 'EU',
      ),
    );
    await tester.pump();

    expect(find.text('Türkiye'), findsOneWidget);
    expect(find.textContaining('Europe'), findsWidgets);

    final DropdownButton<String?> dropdown = tester.widget(
      find.byType(DropdownButton<String?>),
    );
    expect(dropdown.value, 'EU');

    dropdown.onChanged?.call(null);
    expect(cubit.selectCalls, contains(null));
  });

  testWidgets('GraphqlDemoPage disables filter while loading', (
    WidgetTester tester,
  ) async {
    final _StubGraphqlDemoCubit cubit = _StubGraphqlDemoCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(_wrapWithCubit(cubit));

    cubit.emit(
      GraphqlDemoState(
        status: ViewStatus.loading,
        continents: const <GraphqlContinent>[
          GraphqlContinent(code: 'AF', name: 'Africa'),
        ],
      ),
    );
    await tester.pump();

    final DropdownButton<String?> dropdown = tester.widget(
      find.byType(DropdownButton<String?>),
    );
    expect(dropdown.onChanged, isNull);
  });
}

Widget _wrapWithCubit(GraphqlDemoCubit cubit) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<GraphqlDemoCubit>.value(
      value: cubit,
      child: const GraphqlDemoPage(),
    ),
  );
}

class _StubGraphqlDemoCubit extends GraphqlDemoCubit {
  _StubGraphqlDemoCubit() : super(repository: _StubGraphqlRepository());

  final List<String?> selectCalls = <String?>[];

  @override
  Future<void> selectContinent(String? continentCode, {bool force = false}) {
    selectCalls.add(continentCode);
    return Future<void>.value();
  }

  @override
  Future<void> refresh() async {}
}

class _StubGraphqlRepository implements GraphqlDemoRepository {
  @override
  Future<List<GraphqlContinent>> fetchContinents() async =>
      const <GraphqlContinent>[];

  @override
  Future<List<GraphqlCountry>> fetchCountries({String? continentCode}) async =>
      const <GraphqlCountry>[];
}
