import 'dart:async';

import 'package:flutter_bloc_app/app/analytics/analytics_consent_repository.dart';
import 'package:flutter_bloc_app/app/analytics/in_memory_product_analytics.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/analytics_consent_section.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpSection(
    WidgetTester tester, {
    required AnalyticsConsentRepository consent,
    required InMemoryProductAnalytics analytics,
    Key? key,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AnalyticsConsentSection(
            key: key,
            analyticsConsentRepository: consent,
            productAnalytics: analytics,
          ),
        ),
      ),
    );
  }

  testWidgets('AnalyticsConsentSection toggles consent', (tester) async {
    final _FakeConsent consent = _FakeConsent();
    addTearDown(consent.dispose);
    final InMemoryProductAnalytics analytics = InMemoryProductAnalytics();

    await pumpSection(tester, consent: consent, analytics: analytics);
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
    tester,
  ) async {
    final _FakeConsent consent = _FakeConsent();
    addTearDown(consent.dispose);
    final InMemoryProductAnalytics analytics = InMemoryProductAnalytics();

    await pumpSection(tester, consent: consent, analytics: analytics);
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

  testWidgets('AnalyticsConsentSection rolls back when save fails', (
    tester,
  ) async {
    final _FakeConsent consent = _FakeConsent()..failNextSave = true;
    addTearDown(consent.dispose);
    final InMemoryProductAnalytics analytics = InMemoryProductAnalytics();

    await pumpSection(tester, consent: consent, analytics: analytics);
    await tester.pumpAndSettle();

    final Finder switchFinder = find.byKey(
      const ValueKey('settings-analytics-consent-switch'),
    );
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    expect(tester.widget<SwitchListTile>(switchFinder).value, isFalse);
    expect(consent.enabled, isFalse);
    expect(analytics.collectionEnabled, isFalse);
  });

  testWidgets('AnalyticsConsentSection cancels consent stream on dispose', (
    tester,
  ) async {
    final _FakeConsent consent = _FakeConsent();
    addTearDown(consent.dispose);
    final InMemoryProductAnalytics analytics = InMemoryProductAnalytics();

    await pumpSection(tester, consent: consent, analytics: analytics);
    await tester.pumpAndSettle();

    expect(consent.hasListener, isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(consent.hasListener, isFalse);
  });

  testWidgets('AnalyticsConsentSection disables toggle while save is pending', (
    tester,
  ) async {
    final Completer<bool> saveGate = Completer<bool>();
    final _FakeConsent consent = _FakeConsent()..pendingSave = saveGate;
    addTearDown(consent.dispose);
    final InMemoryProductAnalytics analytics = InMemoryProductAnalytics();

    await pumpSection(tester, consent: consent, analytics: analytics);
    await tester.pumpAndSettle();

    final Finder switchFinder = find.byKey(
      const ValueKey('settings-analytics-consent-switch'),
    );
    await tester.tap(switchFinder);
    await tester.pump();

    expect(tester.widget<SwitchListTile>(switchFinder).onChanged, isNull);

    saveGate.complete(true);
    await tester.pumpAndSettle();

    expect(tester.widget<SwitchListTile>(switchFinder).onChanged, isNotNull);
    expect(tester.widget<SwitchListTile>(switchFinder).value, isTrue);
    expect(analytics.collectionEnabled, isTrue);
  });

  testWidgets(
    'AnalyticsConsentSection ignores stale save after repository replacement',
    (tester) async {
      final Completer<bool> pendingSave = Completer<bool>();
      final _FakeConsent consentA = _FakeConsent()..pendingSave = pendingSave;
      final _FakeConsent consentB = _FakeConsent();
      addTearDown(consentA.dispose);
      addTearDown(consentB.dispose);
      final InMemoryProductAnalytics analytics = InMemoryProductAnalytics();
      const Key sectionKey = ValueKey<String>('analytics-consent-section');

      await pumpSection(
        tester,
        key: sectionKey,
        consent: consentA,
        analytics: analytics,
      );
      await tester.pumpAndSettle();

      final Finder switchFinder = find.byKey(
        const ValueKey('settings-analytics-consent-switch'),
      );
      await tester.tap(switchFinder);
      await tester.pump();

      await pumpSection(
        tester,
        key: sectionKey,
        consent: consentB,
        analytics: analytics,
      );
      await tester.pump();

      pendingSave.complete(true);
      await tester.pumpAndSettle();

      expect(tester.widget<SwitchListTile>(switchFinder).value, isFalse);
      expect(consentB.enabled, isFalse);
      expect(analytics.collectionEnabled, isFalse);
    },
  );

  testWidgets(
    'AnalyticsConsentSection rebinds when consent repository is replaced',
    (tester) async {
      final _FakeConsent consentA = _FakeConsent();
      final _FakeConsent consentB = _FakeConsent()..enabled = true;
      addTearDown(consentA.dispose);
      addTearDown(consentB.dispose);
      final InMemoryProductAnalytics analytics = InMemoryProductAnalytics();
      const Key sectionKey = ValueKey<String>('analytics-consent-section');

      await pumpSection(
        tester,
        key: sectionKey,
        consent: consentA,
        analytics: analytics,
      );
      await tester.pumpAndSettle();

      expect(consentA.hasListener, isTrue);
      expect(
        tester
            .widget<SwitchListTile>(
              find.byKey(const ValueKey('settings-analytics-consent-switch')),
            )
            .value,
        isFalse,
      );

      await pumpSection(
        tester,
        key: sectionKey,
        consent: consentB,
        analytics: analytics,
      );
      await tester.pumpAndSettle();

      expect(consentA.hasListener, isFalse);
      expect(consentB.hasListener, isTrue);
      expect(
        tester
            .widget<SwitchListTile>(
              find.byKey(const ValueKey('settings-analytics-consent-switch')),
            )
            .value,
        isTrue,
      );

      await consentB.save(enabled: false);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<SwitchListTile>(
              find.byKey(const ValueKey('settings-analytics-consent-switch')),
            )
            .value,
        isFalse,
      );
    },
  );
}

class _FakeConsent implements AnalyticsConsentRepository {
  bool enabled = false;
  bool failNextSave = false;
  Completer<bool>? pendingSave;
  final StreamController<bool> _changes = StreamController<bool>.broadcast();

  bool get hasListener => _changes.hasListener;

  @override
  Stream<bool> get changes => _changes.stream;

  @override
  Future<bool> load() async => enabled;

  @override
  Future<bool> save({required bool enabled}) async {
    if (failNextSave) {
      failNextSave = false;
      return false;
    }
    if (pendingSave != null) {
      final Completer<bool> gate = pendingSave!;
      pendingSave = null;
      final bool allowed = await gate.future;
      if (!allowed) {
        return false;
      }
    }
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
