part of 'test_harness.dart';

class _FakeBiometricAuthenticator implements BiometricAuthenticator {
  _FakeBiometricAuthenticator({required final bool result}) : _result = result;

  final bool _result;

  @override
  Future<bool> authenticate({final String? localizedReason}) async => _result;
}

class _FakeAppInfoRepository implements AppInfoRepository {
  @override
  Future<AppInfo> load() async =>
      const AppInfo(version: '1.2.3', buildNumber: '42');
}

class _FixedLocaleRepository implements LocaleRepository {
  _FixedLocaleRepository({required final AppLocale? initialLocale})
    : _locale = initialLocale;

  AppLocale? _locale;

  @override
  Future<AppLocale?> load() async => _locale;

  @override
  Future<void> save(final AppLocale? locale) async {
    _locale = locale;
  }
}

class _FakeChartRepository extends ChartRepository {
  const _FakeChartRepository();

  static final List<ChartPoint> _points = <ChartPoint>[
    ChartPoint(date: DateTime.utc(2026), value: 42000),
    ChartPoint(date: DateTime.utc(2026, 1, 2), value: 42100),
    ChartPoint(date: DateTime.utc(2026, 1, 3), value: 41950),
  ];

  @override
  Future<List<ChartPoint>> fetchTrendingCounts() async => _points;

  @override
  List<ChartPoint>? getCachedTrendingCounts() => _points;

  @override
  ChartDataSource get lastSource => ChartDataSource.cache;
}

Future<void> _overrideChartRepository() async {
  if (getIt.isRegistered<ChartRepository>()) {
    await getIt.unregister<ChartRepository>();
  }
  getIt.registerSingleton<ChartRepository>(const _FakeChartRepository());
}

class _FakeGraphqlDemoRepository implements GraphqlDemoRepository {
  const _FakeGraphqlDemoRepository();

  static const List<GraphqlContinent> _continents = <GraphqlContinent>[
    GraphqlContinent(code: 'EU', name: 'Europe'),
    GraphqlContinent(code: 'NA', name: 'North America'),
  ];

  static const List<GraphqlCountry> _countries = <GraphqlCountry>[
    GraphqlCountry(
      code: 'DE',
      name: 'Germany',
      continent: GraphqlContinent(code: 'EU', name: 'Europe'),
      capital: 'Berlin',
      currency: 'EUR',
      emoji: '🇩🇪',
    ),
    GraphqlCountry(
      code: 'US',
      name: 'United States',
      continent: GraphqlContinent(code: 'NA', name: 'North America'),
      capital: 'Washington, D.C.',
      currency: 'USD',
      emoji: '🇺🇸',
    ),
  ];

  @override
  GraphqlDataSource get lastSource => GraphqlDataSource.cache;

  @override
  Future<List<GraphqlContinent>> fetchContinents() async => _continents;

  @override
  Future<List<GraphqlCountry>> fetchCountries({
    final String? continentCode,
  }) async {
    if (continentCode == null) {
      return _countries;
    }
    return _countries
        .where((final country) => country.continent.code == continentCode)
        .toList(growable: false);
  }
}

Future<void> _overrideGraphqlRepository({
  final bool failOnceThenSuccess = false,
}) async {
  if (getIt.isRegistered<GraphqlDemoRepository>()) {
    await getIt.unregister<GraphqlDemoRepository>();
  }
  final GraphqlDemoRepository repo = failOnceThenSuccess
      ? GraphqlFailOnceNetworkRepository()
      : const _FakeGraphqlDemoRepository();
  getIt.registerSingleton<GraphqlDemoRepository>(repo);
}
