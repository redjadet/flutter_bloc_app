import 'package:flutter_bloc_app/app/analytics/app_analytics_event.dart';
import 'package:flutter_bloc_app/app/analytics/firebase_product_analytics.dart';
import 'package:flutter_bloc_app/app/analytics/in_memory_product_analytics.dart';
import 'package:flutter_bloc_app/app/analytics/shared_preferences_analytics_consent_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SharedPreferencesAnalyticsConsentRepository', () {
    test('load defaults to false when key missing', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferencesAnalyticsConsentRepository repo =
          SharedPreferencesAnalyticsConsentRepository(
            await SharedPreferences.getInstance(),
          );
      addTearDown(repo.dispose);

      expect(await repo.load(), isFalse);
    });

    test('save and load round-trip', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final SharedPreferencesAnalyticsConsentRepository repo =
          SharedPreferencesAnalyticsConsentRepository(prefs);
      addTearDown(repo.dispose);

      await repo.save(enabled: true);
      expect(await repo.load(), isTrue);
      expect(prefs.getBool('analytics_collection_enabled'), isTrue);

      await repo.save(enabled: false);
      expect(await repo.load(), isFalse);
    });

    test('save emits changes stream', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferencesAnalyticsConsentRepository repo =
          SharedPreferencesAnalyticsConsentRepository(
            await SharedPreferences.getInstance(),
          );
      addTearDown(repo.dispose);
      final Future<bool> next = repo.changes.first;
      expect(await repo.save(enabled: true), isTrue);
      expect(await next, isTrue);
    });

    test('dispose closes changes stream', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferencesAnalyticsConsentRepository repo =
          SharedPreferencesAnalyticsConsentRepository(
            await SharedPreferences.getInstance(),
          );
      final Future<void> done = repo.changes.drain<void>();
      await repo.dispose();
      await done;
      expect(await repo.save(enabled: true), isTrue);
    });
  });

  group('AppAnalyticsEvent allowlist', () {
    test('named factories only expose allowlisted keys', () {
      final AppAnalyticsEvent event = AppAnalyticsEvent.showcaseOpened(
        mode: 'simulated',
        source: 'production_readiness',
      );
      expect(
        event.parameters.keys,
        everyElement(isIn(AppAnalyticsEvent.allowedParameterKeys)),
      );
    });

    test('validateParameters rejects unknown keys', () {
      expect(
        () => AppAnalyticsEvent.validateParameters(<String, Object?>{
          'token': 'abc',
        }),
        throwsArgumentError,
      );
    });

    test('validateParameters rejects email-like values', () {
      expect(
        () => AppAnalyticsEvent.validateParameters(<String, Object?>{
          'source': 'user@example.com',
        }),
        throwsArgumentError,
      );
    });
    test('validateParameters rejects UUID-like identifiers', () {
      expect(
        () => AppAnalyticsEvent.validateParameters(<String, Object?>{
          'source': '550e8400-e29b-41d4-a716-446655440000',
        }),
        throwsArgumentError,
      );
    });

    test('validateParameters rejects long hex identifiers', () {
      expect(
        () => AppAnalyticsEvent.validateParameters(<String, Object?>{
          'mode': 'deadbeefdeadbeefdeadbeefdeadbeef',
        }),
        throwsArgumentError,
      );
    });

    test('parameters map is unmodifiable', () {
      final AppAnalyticsEvent event = AppAnalyticsEvent.showcaseOpened(
        mode: 'simulated',
        source: 'production_readiness',
      );
      expect(() => event.parameters['mode'] = 'live', throwsUnsupportedError);
    });

    test('coerceToken falls back for illegal remote values', () {
      expect(
        AppAnalyticsEvent.coerceToken('user@example.com', fallback: 'defaults'),
        'defaults',
      );
      expect(
        AppAnalyticsEvent.coerceToken('remote', fallback: 'defaults'),
        'remote',
      );
    });
  });

  group('InMemoryProductAnalytics', () {
    test('does not record while collection disabled', () async {
      final InMemoryProductAnalytics analytics = InMemoryProductAnalytics();
      await analytics.track(
        AppAnalyticsEvent.demoActionCompleted(result: 'ok', source: 'test'),
      );
      expect(analytics.eventCount, 0);
    });

    test('records when enabled and bounds at maxEvents', () async {
      final InMemoryProductAnalytics analytics = InMemoryProductAnalytics(
        maxEvents: 3,
      );
      await analytics.setCollectionEnabled(enabled: true);
      for (int i = 0; i < 5; i++) {
        await analytics.track(
          AppAnalyticsEvent.demoActionCompleted(
            result: 'ok',
            source: 'test_$i',
          ),
        );
      }
      expect(analytics.eventCount, 3);
      expect(analytics.events.first.parameters['source'], 'test_2');
    });

    test('clearing collection clears buffer', () async {
      final InMemoryProductAnalytics analytics = InMemoryProductAnalytics();
      await analytics.setCollectionEnabled(enabled: true);
      await analytics.track(
        AppAnalyticsEvent.showcaseOpened(mode: 'live', source: 'test'),
      );
      await analytics.setCollectionEnabled(enabled: false);
      expect(analytics.eventCount, 0);
    });
  });

  group('FirebaseProductAnalytics', () {
    test('does not log while collection disabled', () async {
      final _FakeGateway gateway = _FakeGateway();
      final FirebaseProductAnalytics analytics = FirebaseProductAnalytics(
        gateway,
      );

      await analytics.track(
        AppAnalyticsEvent.notificationReceived(mode: 'live', source: 'fcm'),
      );

      expect(gateway.events, isEmpty);
      expect(gateway.collectionEnabled, isNull);
    });

    test('enables collection then logs allowlisted event', () async {
      final _FakeGateway gateway = _FakeGateway();
      final FirebaseProductAnalytics analytics = FirebaseProductAnalytics(
        gateway,
      );

      await analytics.setCollectionEnabled(enabled: true);
      await analytics.track(
        AppAnalyticsEvent.notificationOpened(mode: 'live', source: 'fcm'),
      );

      expect(gateway.collectionEnabled, isTrue);
      expect(gateway.events, hasLength(1));
      expect(gateway.events.single.name, 'notification_opened');
    });
  });
}

class _FakeGateway implements FirebaseAnalyticsGateway {
  bool? collectionEnabled;
  final List<({String name, Map<String, Object>? parameters})> events =
      <({String name, Map<String, Object>? parameters})>[];

  @override
  Future<void> setAnalyticsCollectionEnabled({
    required final bool enabled,
  }) async {
    collectionEnabled = enabled;
  }

  @override
  Future<void> logEvent({
    required final String name,
    final Map<String, Object>? parameters,
  }) async {
    events.add((name: name, parameters: parameters));
  }
}
