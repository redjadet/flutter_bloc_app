import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/analytics/analytics_consent_repository.dart';
import 'package:flutter_bloc_app/app/analytics/in_memory_product_analytics.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/analytics_consent_section.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AnalyticsConsentSection hides when DI not registered', (
    final tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: AnalyticsConsentSection()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('settings-analytics-consent-switch')),
      findsNothing,
    );
  });

  testWidgets('AnalyticsConsentSection toggles consent', (final tester) async {
    final _FakeConsent consent = _FakeConsent();
    addTearDown(consent.dispose);
    final InMemoryProductAnalytics analytics = InMemoryProductAnalytics();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AnalyticsConsentSection(
            consentRepository: consent,
            analytics: analytics,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Finder switchFinder = find.byKey(
      const ValueKey('settings-analytics-consent-switch'),
    );
    expect(switchFinder, findsOneWidget);
    expect(tester.widget<SwitchListTile>(switchFinder).value, isFalse);

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    expect(consent.enabled, isTrue);
    expect(analytics.collectionEnabled, isTrue);
  });

  testWidgets('AnalyticsConsentSection syncs from external save', (
    final tester,
  ) async {
    final _FakeConsent consent = _FakeConsent();
    addTearDown(consent.dispose);
    final InMemoryProductAnalytics analytics = InMemoryProductAnalytics();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AnalyticsConsentSection(
            consentRepository: consent,
            analytics: analytics,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await consent.save(enabled: true);
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<SwitchListTile>(
            find.byKey(const ValueKey('settings-analytics-consent-switch')),
          )
          .value,
      isTrue,
    );
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
  Future<bool> save({required final bool enabled}) async {
    this.enabled = enabled;
    _changes.add(enabled);
    return true;
  }

  @override
  Future<void> dispose() async {
    if (!_changes.isClosed) {
      await _changes.close();
    }
  }
}
