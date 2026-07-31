import 'dart:async';

import 'package:feature_flags/feature_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/analytics/analytics_consent_repository.dart';
import 'package:flutter_bloc_app/app/analytics/in_memory_product_analytics.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_demo_mode.dart';
import 'package:flutter_bloc_app/features/production_readiness/production_readiness.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpPage(
    final WidgetTester tester, {
    required final ProductionReadinessCubit cubit,
    final bool showSimulatedButton = false,
    final double textScale = 1,
    final Size size = const Size(360, 800),
    final Locale locale = const Locale('en'),
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
        ),
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<ProductionReadinessCubit>.value(
            value: cubit,
            child: ProductionReadinessPage(
              showSimulatedNotificationButton: showSimulatedButton,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('ProductionReadinessPage', () {
    late _FakeRemoteConfig remoteConfig;
    late _FakeConsent consent;
    late InMemoryProductAnalytics analytics;
    late ProductionReadinessCubit cubit;

    setUp(() async {
      remoteConfig = _FakeRemoteConfig();
      consent = _FakeConsent();
      analytics = InMemoryProductAnalytics();
      cubit = ProductionReadinessCubit(
        remoteConfig: remoteConfig,
        consentRepository: consent,
        analytics: analytics,
        memoryAnalytics: analytics,
        firebaseInitialized: false,
        fcmMode: FcmDemoMode.simulated,
      );
      await cubit.initialize();
    });

    tearDown(() async {
      await cubit.close();
    });

    testWidgets('renders diagnostic cards at 360px', (final tester) async {
      await pumpPage(tester, cubit: cubit, showSimulatedButton: true);

      expect(
        find.byKey(const ValueKey('production-readiness-mode-card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('production-readiness-crashlytics-card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('production-readiness-fcm-card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('production-readiness-frame-card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('production-readiness-consent-card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('production-readiness-release-card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('production-readiness-settings-link')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('production-readiness-native-showcase-link')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('production-readiness-emit-simulated')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('production-readiness-placeholder')),
        findsNothing,
      );
    });

    testWidgets('shows kill-switch banner when release flag disabled', (
      final tester,
    ) async {
      remoteConfig.enabled = false;
      await cubit.refreshReleaseFlag();
      await pumpPage(tester, cubit: cubit);

      expect(
        find.byKey(const ValueKey('production-readiness-kill-switch')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('production-readiness-list')),
        findsOneWidget,
      );
    });

    testWidgets('renders at 1024px and textScale 2.0', (final tester) async {
      await pumpPage(
        tester,
        cubit: cubit,
        size: const Size(1024, 800),
        textScale: 2,
      );
      expect(
        find.byKey(const ValueKey('production-readiness-list')),
        findsOneWidget,
      );
    });

    testWidgets('renders Arabic RTL locale', (final tester) async {
      await pumpPage(tester, cubit: cubit, locale: const Locale('ar'));
      expect(
        find.byKey(const ValueKey('production-readiness-mode-card')),
        findsOneWidget,
      );
    });
  });
}

class _FakeConsent implements AnalyticsConsentRepository {
  bool enabled = false;
  final StreamController<bool> _changes = StreamController<bool>.broadcast();

  @override
  Stream<bool> get changes => _changes.stream;

  @override
  Future<bool> load() async => enabled;

  @override
  Future<void> save({required final bool enabled}) async {
    this.enabled = enabled;
    _changes.add(enabled);
  }
}

class _FakeRemoteConfig implements RemoteConfigService {
  bool enabled = true;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> forceFetch() async {}

  @override
  Future<void> clearCache() async {}

  @override
  bool getBool(final String key) =>
      enabled && key == RemoteConfigKeys.productionDemoEnabled;

  @override
  String getString(final String key) {
    if (key == RemoteConfigKeys.productionDemoVariant) {
      return 'control';
    }
    if (key == RemoteConfigKeys.lastDataSource) {
      return 'defaults';
    }
    return '';
  }

  @override
  int getInt(final String key) => 0;

  @override
  double getDouble(final String key) => 0;
}
