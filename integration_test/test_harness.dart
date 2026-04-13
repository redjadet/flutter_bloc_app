import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_data_source.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_data_source.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_info.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_info_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_locale.dart';
import 'package:flutter_bloc_app/features/settings/domain/locale_repository.dart';
import 'package:flutter_bloc_app/shared/platform/biometric_authenticator.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../test/test_helpers.dart' as test_helpers;
import '../test/test_helpers.dart' show waitForCounterCubitsToLoad;
import 'graphql_fail_once_repository.dart';
import 'widget_tester_pumps.dart';

export 'widget_tester_pumps.dart';

part 'test_harness_fakes.dart';
part 'test_harness_log_filters.dart';

bool _hiveInitialized = false;
final List<AppLogEntry> _unexpectedIntegrationLogs = <AppLogEntry>[];

class IntegrationDependencyOptions {
  const IntegrationDependencyOptions({
    this.overrideCounterRepository = true,
    this.overrideChartRepository = true,
    this.overrideGraphqlRepository = true,
    this.graphqlFailOnceThenSuccess = false,
    this.setFlavorToProd = true,
    this.biometricSuccess = true,
    this.locale = const AppLocale(languageCode: 'en'),
    this.authMode = IntegrationAuthMode.mockFirebaseAuth,
  });

  final bool overrideCounterRepository;
  final bool overrideChartRepository;
  final bool overrideGraphqlRepository;

  /// See [GraphqlFailOnceNetworkRepository].
  final bool graphqlFailOnceThenSuccess;
  final bool setFlavorToProd;
  final bool biometricSuccess;
  final AppLocale? locale;
  final IntegrationAuthMode authMode;
}

enum IntegrationAuthMode {
  /// Uses `firebase_auth_mocks` (default for most tests).
  mockFirebaseAuth,

  /// Uses real plugin-backed Firebase Auth (email/password) for dev projects.
  realFirebaseAuth,
}

void registerIntegrationHarness() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(initializeIntegrationTestHarness);
}

void registerIntegrationFlow({
  required final String groupName,
  required final String testName,
  required final WidgetTesterCallback body,
  final IntegrationDependencyOptions options =
      const IntegrationDependencyOptions(),
}) {
  group(groupName, () {
    setUp(() async {
      _beginIntegrationLogCapture();
      await configureIntegrationTestDependencies(
        overrideCounterRepository: options.overrideCounterRepository,
        overrideChartRepository: options.overrideChartRepository,
        overrideGraphqlRepository: options.overrideGraphqlRepository,
        graphqlFailOnceThenSuccess: options.graphqlFailOnceThenSuccess,
        setFlavorToProd: options.setFlavorToProd,
        biometricSuccess: options.biometricSuccess,
        locale: options.locale,
        authMode: options.authMode,
      );
    });

    tearDown(() async {
      _assertNoUnexpectedIntegrationLogs();
      _endIntegrationLogCapture();
      await tearDownIntegrationTestDependencies();
    });

    testWidgets(testName, (final tester) async {
      try {
        await body(tester);
      } finally {
        await _postTestCleanupPumps(tester);
      }
    });
  });
}

Future<void> initializeIntegrationTestHarness() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  if (_hiveInitialized) {
    return;
  }

  await test_helpers.setupHiveForTesting();
  _hiveInitialized = true;
}

void _beginIntegrationLogCapture() {
  _unexpectedIntegrationLogs.clear();
  AppLogger.observer = (final entry) {
    if (_isUnexpectedIntegrationLog(entry)) {
      _unexpectedIntegrationLogs.add(entry);
    }
  };
}

void _endIntegrationLogCapture() {
  AppLogger.observer = null;
  _unexpectedIntegrationLogs.clear();
}

void _assertNoUnexpectedIntegrationLogs() {
  if (_unexpectedIntegrationLogs.isEmpty) {
    return;
  }

  final String details = _unexpectedIntegrationLogs
      .map((final entry) {
        final StringBuffer buffer = StringBuffer()
          ..write(entry.level.name)
          ..write(': ')
          ..write(entry.message);
        if (entry.error != null) {
          buffer
            ..write(' | error=')
            ..write(entry.error);
        }
        return buffer.toString();
      })
      .join('\n');
  fail('Unexpected warning/error logs during integration test:\n$details');
}

Future<void> configureIntegrationTestDependencies({
  final bool overrideCounterRepository = true,
  final bool overrideChartRepository = true,
  final bool overrideGraphqlRepository = true,
  final bool graphqlFailOnceThenSuccess = false,
  final bool setFlavorToProd = true,
  final bool biometricSuccess = true,
  final AppLocale? locale = const AppLocale(languageCode: 'en'),
  final IntegrationAuthMode authMode = IntegrationAuthMode.mockFirebaseAuth,
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
      useMockFirebasePlatform: authMode == IntegrationAuthMode.mockFirebaseAuth,
      useMockFirebaseAuth: authMode == IntegrationAuthMode.mockFirebaseAuth,
    ),
  );

  await _overrideBiometricAuthenticator(biometricSuccess);
  await _overrideAppInfoRepository();
  await _overrideLocaleRepository(locale);
  if (overrideChartRepository) {
    await _overrideChartRepository();
  }
  if (overrideGraphqlRepository) {
    await _overrideGraphqlRepository(
      failOnceThenSuccess: graphqlFailOnceThenSuccess,
    );
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
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> restartTestApp(
  final WidgetTester tester, {
  final bool requireAuth = false,
}) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await pumpSettleWithin(
    tester,
    timeout: const Duration(seconds: 4),
  );
  await launchTestApp(tester, requireAuth: requireAuth);
}

Future<void> _postTestCleanupPumps(final WidgetTester tester) async {
  // Keep cleanup lightweight. Avoid unmounting the whole widget tree here since
  // the integration device runner manages app lifecycle (install/launch/kill).
  try {
    await pumpSettleWithin(
      tester,
      timeout: const Duration(seconds: 2),
    );
  } on TestFailure {
    // Best-effort: leave the app as-is but give pending callbacks a tiny
    // window to flush, so teardown doesn't hang.
    await tester.pump(const Duration(milliseconds: 250));
  }
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
