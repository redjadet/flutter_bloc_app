import 'dart:async';

import 'package:feature_flags/feature_flags.dart';
import 'package:flutter_bloc_app/app/analytics/analytics_consent_repository.dart';
import 'package:flutter_bloc_app/app/analytics/in_memory_product_analytics.dart';
import 'package:flutter_bloc_app/app/analytics/shared_preferences_analytics_consent_repository.dart';
import 'package:flutter_bloc_app/app/diagnostics/frame_timing_monitor.dart';
import 'package:flutter_bloc_app/features/fcm_demo/data/simulated_fcm_messaging_service.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_demo_mode.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_messaging_service.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_permission_state.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/push_message.dart';
import 'package:flutter_bloc_app/features/production_readiness/presentation/cubit/production_readiness_cubit.dart';
import 'package:flutter_bloc_app/features/production_readiness/presentation/cubit/production_readiness_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ProductionReadinessCubit', () {
    late _FakeRemoteConfig remoteConfig;
    late _FakeConsent consent;
    late InMemoryProductAnalytics analytics;
    late ProductionReadinessCubit cubit;

    setUp(() {
      remoteConfig = _FakeRemoteConfig();
      consent = _FakeConsent();
      analytics = InMemoryProductAnalytics();
      cubit = ProductionReadinessCubit(
        remoteConfig: remoteConfig,
        consentRepository: consent,
        analytics: analytics,
        memoryAnalytics: analytics,
        firebaseInitialized: false,
      );
    });

    tearDown(() async {
      await cubit.close();
      await consent.dispose();
    });

    test('initialize uses simulated mode and defaults consent off', () async {
      await cubit.initialize();

      expect(cubit.state.status, ProductionReadinessStatus.ready);
      expect(cubit.state.mode, ProductionReadinessMode.simulated);
      expect(cubit.state.analyticsConsentEnabled, isFalse);
      expect(cubit.state.releaseFlagEnabled, isTrue);
      expect(cubit.state.releaseVariant, 'control');
      expect(cubit.state.crashlyticsAvailable, isFalse);
      expect(analytics.eventCount, 0);
    });

    test('tracks showcase after consent enabled', () async {
      await consent.save(enabled: true);
      await cubit.initialize();

      expect(analytics.eventCount, greaterThan(0));
      expect(
        analytics.events.map((final e) => e.name),
        containsAll(<String>['showcase_opened', 'release_flag_evaluated']),
      );
    });

    test('setAnalyticsConsent updates state and adapter', () async {
      await cubit.initialize();
      await cubit.setAnalyticsConsent(enabled: true);

      expect(cubit.state.analyticsConsentEnabled, isTrue);
      expect(consent.enabled, isTrue);
      expect(analytics.collectionEnabled, isTrue);
    });

    test('refreshReleaseFlag reflects disabled kill-switch', () async {
      await cubit.initialize();
      remoteConfig.enabled = false;
      remoteConfig.variant = 'treatment';
      remoteConfig.source = 'remote';

      await cubit.refreshReleaseFlag();

      expect(cubit.state.releaseFlagEnabled, isFalse);
      expect(cubit.state.releaseVariant, 'treatment');
      expect(cubit.state.configSource, 'remote');
    });

    test('refreshReleaseFlag keeps cache when fetch fails', () async {
      await cubit.initialize();
      remoteConfig.enabled = false;
      remoteConfig.variant = 'cached-variant';
      remoteConfig.source = 'cache';
      remoteConfig.forceFetchThrows = true;

      await cubit.refreshReleaseFlag();

      expect(cubit.state.releaseFlagEnabled, isFalse);
      expect(cubit.state.releaseVariant, 'cached-variant');
      expect(cubit.state.configSource, 'cache');
    });

    test('refreshReleaseFlag no-ops emit after close during async', () async {
      remoteConfig.forceFetchDelay = const Duration(milliseconds: 50);
      final Future<void> init = cubit.initialize();
      await init;
      final Future<void> refresh = cubit.refreshReleaseFlag();
      await cubit.close();
      await refresh;
      expect(cubit.isClosed, isTrue);
    });

    test('wires FCM and frame monitor summaries', () async {
      final SimulatedFcmMessagingService messaging =
          SimulatedFcmMessagingService();
      final _FakeFrameMonitor frameMonitor = _FakeFrameMonitor();
      addTearDown(() async {
        await messaging.dispose();
        frameMonitor.stop();
      });

      final ProductionReadinessCubit wired = ProductionReadinessCubit(
        remoteConfig: remoteConfig,
        consentRepository: consent,
        analytics: analytics,
        memoryAnalytics: analytics,
        messaging: messaging,
        frameMonitor: frameMonitor,
        simulationController: messaging,
        fcmMode: FcmDemoMode.simulated,
        firebaseInitialized: true,
      );
      addTearDown(wired.close);

      await wired.initialize();

      expect(wired.state.crashlyticsAvailable, isTrue);
      expect(wired.state.fcmMode, FcmDemoMode.simulated);
      expect(wired.state.fcmPermission, FcmPermissionState.authorized);

      frameMonitor.emitSummary(
        const FrameTimingSummary(
          sampleCount: 3,
          p90Ms: 18,
          p99Ms: 22,
          missedOver16_7Ms: 1,
        ),
      );
      expect(wired.state.frameSampleCount, 3);
      expect(wired.state.frameP90Ms, 18);

      final Future<PushMessage> next = messaging.foregroundMessages.first;
      wired.emitSimulatedNotification();
      final PushMessage message = await next;
      expect(wired.state.fcmHasTitle, isTrue);
      expect(wired.state.fcmHasBody, isTrue);
      expect(wired.state.fcmLastSource, message.source.name);
    });

    test('keeps demo ready when FCM setup throws', () async {
      final ProductionReadinessCubit wired = ProductionReadinessCubit(
        remoteConfig: remoteConfig,
        consentRepository: consent,
        analytics: analytics,
        memoryAnalytics: analytics,
        messaging: _ThrowingFcmMessagingService(),
        fcmMode: FcmDemoMode.live,
        firebaseInitialized: true,
      );
      addTearDown(wired.close);

      await wired.initialize();

      expect(wired.state.status, ProductionReadinessStatus.ready);
      expect(wired.state.errorMessage, isNotNull);
    });

    test('simulated notification tracks exactly once with consent', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'analytics_collection_enabled': true,
      });
      final SharedPreferencesAnalyticsConsentRepository consented =
          SharedPreferencesAnalyticsConsentRepository(
            await SharedPreferences.getInstance(),
          );
      addTearDown(consented.dispose);
      final SimulatedFcmMessagingService messaging =
          SimulatedFcmMessagingService();
      addTearDown(messaging.dispose);

      final ProductionReadinessCubit wired = ProductionReadinessCubit(
        remoteConfig: remoteConfig,
        consentRepository: consented,
        analytics: analytics,
        memoryAnalytics: analytics,
        messaging: messaging,
        simulationController: messaging,
        fcmMode: FcmDemoMode.simulated,
        firebaseInitialized: false,
      );
      addTearDown(wired.close);

      await wired.initialize();
      // showcase + release_flag while consent enabled
      final int baseline = analytics.eventCount;
      expect(baseline, greaterThan(0));

      wired.emitSimulatedNotification();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final int notificationEvents = analytics.events
          .where((final e) => e.name == 'notification_received')
          .length;
      expect(notificationEvents, 1);
    });

    test('simulated notification does not track without consent', () async {
      final SimulatedFcmMessagingService messaging =
          SimulatedFcmMessagingService();
      addTearDown(messaging.dispose);

      final ProductionReadinessCubit wired = ProductionReadinessCubit(
        remoteConfig: remoteConfig,
        consentRepository: consent,
        analytics: analytics,
        memoryAnalytics: analytics,
        messaging: messaging,
        simulationController: messaging,
        fcmMode: FcmDemoMode.simulated,
        firebaseInitialized: false,
      );
      addTearDown(wired.close);

      await wired.initialize();
      expect(analytics.eventCount, 0);
      wired.emitSimulatedNotification();
      await Future<void>.delayed(Duration.zero);
      expect(analytics.eventCount, 0);
    });

    test('refreshReleaseFlag does not track without consent', () async {
      await cubit.initialize();
      expect(analytics.eventCount, 0);
      await cubit.refreshReleaseFlag();
      expect(analytics.eventCount, 0);
    });

    test('external consent save syncs cubit state', () async {
      await cubit.initialize();
      expect(cubit.state.analyticsConsentEnabled, isFalse);

      await consent.save(enabled: true);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.analyticsConsentEnabled, isTrue);
      expect(analytics.collectionEnabled, isTrue);
    });
  });
}

class _FakeFrameMonitor implements FrameTimingMonitor {
  void Function(FrameTimingSummary summary)? _onSummary;

  @override
  FrameTimingSummary currentSummary = FrameTimingSummary.empty;

  void emitSummary(final FrameTimingSummary summary) {
    currentSummary = summary;
    _onSummary?.call(summary);
  }

  @override
  void start({void Function(FrameTimingSummary summary)? onSummary}) {
    _onSummary = onSummary;
    onSummary?.call(currentSummary);
  }

  @override
  void stop() {
    _onSummary = null;
  }
}

class _ThrowingFcmMessagingService implements FcmMessagingService {
  @override
  Stream<PushMessage> get foregroundMessages =>
      const Stream<PushMessage>.empty();

  @override
  Future<PushMessage?> getInitialMessage() async => null;

  @override
  Future<String?> getApnsToken() async => null;

  @override
  Future<String?> getToken() async => null;

  @override
  Stream<PushMessage> get openedMessages => const Stream<PushMessage>.empty();

  @override
  Future<FcmPermissionState> requestPermission() =>
      Future<FcmPermissionState>.error(StateError('platform unavailable'));

  @override
  Stream<String> get tokenRefreshes => const Stream<String>.empty();
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

class _FakeRemoteConfig implements RemoteConfigService {
  bool enabled = true;
  String variant = 'control';
  String source = 'defaults';
  bool forceFetchThrows = false;
  Duration forceFetchDelay = Duration.zero;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> forceFetch() async {
    if (forceFetchDelay > Duration.zero) {
      await Future<void>.delayed(forceFetchDelay);
    }
    if (forceFetchThrows) {
      throw StateError('fetch failed');
    }
  }

  @override
  Future<void> clearCache() async {}

  @override
  bool getBool(final String key) {
    if (key == RemoteConfigKeys.productionDemoEnabled) {
      return enabled;
    }
    return false;
  }

  @override
  String getString(final String key) {
    if (key == RemoteConfigKeys.productionDemoVariant) {
      return variant;
    }
    if (key == RemoteConfigKeys.lastDataSource) {
      return source;
    }
    return '';
  }

  @override
  int getInt(final String key) => 0;

  @override
  double getDouble(final String key) => 0;
}
