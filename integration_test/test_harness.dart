import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_data_source.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_info.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_info_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_locale.dart';
import 'package:flutter_bloc_app/features/settings/domain/locale_repository.dart';
import 'package:flutter_bloc_app/shared/platform/biometric_authenticator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../test/test_helpers.dart' as test_helpers;
import '../test/test_helpers.dart' show waitForCounterCubitsToLoad;

bool _hiveInitialized = false;

Future<void> initializeIntegrationTestHarness() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  if (_hiveInitialized) {
    return;
  }

  await test_helpers.setupHiveForTesting();
  _hiveInitialized = true;
}

Future<void> configureIntegrationTestDependencies({
  final bool overrideCounterRepository = true,
  final bool overrideChartRepository = true,
  final bool setFlavorToProd = true,
  final bool biometricSuccess = true,
  final AppLocale? locale = const AppLocale(languageCode: 'en'),
}) async {
  PackageInfo.setMockInitialValues(
    appName: 'Flutter Demo',
    packageName: 'com.example.flutter_bloc_app',
    version: '1.2.3',
    buildNumber: '42',
    buildSignature: '',
  );

  await test_helpers.setupTestDependencies(
    test_helpers.TestSetupOptions(
      overrideCounterRepository: overrideCounterRepository,
      setFlavorToProd: setFlavorToProd,
    ),
  );

  await _overrideBiometricAuthenticator(biometricSuccess);
  await _overrideAppInfoRepository();
  await _overrideLocaleRepository(locale);
  if (overrideChartRepository) {
    await _overrideChartRepository();
  }
}

Future<void> tearDownIntegrationTestDependencies() =>
    test_helpers.tearDownTestDependencies();

Future<void> launchTestApp(
  final WidgetTester tester, {
  final bool requireAuth = false,
}) async {
  await tester.pumpWidget(MyApp(requireAuth: requireAuth));
  await tester.pump();
  await waitForCounterCubitsToLoad(tester);
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> restartTestApp(
  final WidgetTester tester, {
  final bool requireAuth = false,
}) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  await launchTestApp(tester, requireAuth: requireAuth);
}

Future<void> pumpUntilFound(
  final WidgetTester tester,
  final Finder finder, {
  final Duration timeout = const Duration(seconds: 5),
  final Duration step = const Duration(milliseconds: 100),
}) async {
  final Stopwatch stopwatch = Stopwatch()..start();
  while (stopwatch.elapsed < timeout) {
    await tester.pump(step);
    if (tester.any(finder)) {
      return;
    }
  }

  throw TestFailure('Did not find $finder within ${timeout.inSeconds}s');
}

Future<void> _overrideBiometricAuthenticator(final bool success) async {
  if (getIt.isRegistered<BiometricAuthenticator>()) {
    await getIt.unregister<BiometricAuthenticator>();
  }
  getIt.registerSingleton<BiometricAuthenticator>(
    _FakeBiometricAuthenticator(result: success),
  );
}

Future<void> _overrideAppInfoRepository() async {
  if (getIt.isRegistered<AppInfoRepository>()) {
    await getIt.unregister<AppInfoRepository>();
  }
  getIt.registerSingleton<AppInfoRepository>(_FakeAppInfoRepository());
}

Future<void> _overrideLocaleRepository(final AppLocale? locale) async {
  if (getIt.isRegistered<LocaleRepository>()) {
    await getIt.unregister<LocaleRepository>();
  }
  getIt.registerSingleton<LocaleRepository>(
    _FixedLocaleRepository(initialLocale: locale),
  );
}

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
    // ignore: avoid_redundant_argument_values
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
