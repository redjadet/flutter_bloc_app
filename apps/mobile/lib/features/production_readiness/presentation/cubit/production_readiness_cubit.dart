import 'dart:async';

import 'package:feature_flags/feature_flags.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/analytics/analytics_consent_repository.dart';
import 'package:flutter_bloc_app/app/analytics/app_analytics_event.dart';
import 'package:flutter_bloc_app/app/analytics/in_memory_product_analytics.dart';
import 'package:flutter_bloc_app/app/analytics/product_analytics.dart';
import 'package:flutter_bloc_app/app/bootstrap/firebase_bootstrap_service.dart';
import 'package:flutter_bloc_app/app/diagnostics/frame_timing_monitor.dart';
import 'package:flutter_bloc_app/app/utils/bloc/cubit_subscription_mixin.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_demo_mode.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_messaging_service.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_simulation_controller.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/push_message.dart';
import 'package:flutter_bloc_app/features/production_readiness/presentation/cubit/production_readiness_state.dart';

part 'production_readiness_cubit_fcm.part.dart';

class ProductionReadinessCubit extends _ProductionReadinessCubitBase
    with _ProductionReadinessCubitFcm {
  ProductionReadinessCubit({
    required super.remoteConfig,
    required super.consentRepository,
    required super.analytics,
    super.memoryAnalytics,
    super.messaging,
    super.frameMonitor,
    super.simulationController,
    super.fcmMode,
    super.firebaseInitialized,
  });
}

abstract class _ProductionReadinessCubitBase
    extends Cubit<ProductionReadinessState>
    with CubitSubscriptionMixin<ProductionReadinessState> {
  _ProductionReadinessCubitBase({
    required this._remoteConfig,
    required this._consentRepository,
    required this._analytics,
    this._memoryAnalytics,
    this._messaging,
    this._frameMonitor,
    this._simulationController,
    final FcmDemoMode? fcmMode,
    final bool? firebaseInitialized,
  }) : _fcmMode = fcmMode ?? FcmDemoMode.simulated,
       _firebaseInitialized =
           firebaseInitialized ??
           FirebaseBootstrapService.isFirebaseInitialized,
       super(const ProductionReadinessState());

  static const String fcmStreamErrorMessage =
      'Push notification stream is temporarily unavailable.';

  final RemoteConfigService _remoteConfig;
  final AnalyticsConsentRepository _consentRepository;
  final ProductAnalytics _analytics;
  final InMemoryProductAnalytics? _memoryAnalytics;
  final FcmMessagingService? _messaging;
  final FrameTimingMonitor? _frameMonitor;
  final FcmSimulationController? _simulationController;
  final FcmDemoMode _fcmMode;
  final bool _firebaseInitialized;
  bool _fcmStreamsSubscribed = false;

  Future<void> _initializeFcm();

  void _startFrameMonitor();

  Future<void> _trackNotificationReceived();

  Future<void> initialize() async {
    emit(state.copyWith(status: ProductionReadinessStatus.loading));
    try {
      final ProductionReadinessMode mode = _firebaseInitialized
          ? ProductionReadinessMode.live
          : ProductionReadinessMode.simulated;
      final bool consent = await _consentRepository.load();
      await _analytics.setCollectionEnabled(enabled: consent);

      final bool releaseEnabled = _remoteConfig.getBool(
        RemoteConfigKeys.productionDemoEnabled,
      );
      String variant = _remoteConfig.getString(
        RemoteConfigKeys.productionDemoVariant,
      );
      if (variant.isEmpty) {
        variant = 'control';
      }
      String source = _remoteConfig.getString(RemoteConfigKeys.lastDataSource);
      if (source.isEmpty) {
        source = 'defaults';
      }

      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          status: ProductionReadinessStatus.ready,
          mode: mode,
          analyticsConsentEnabled: consent,
          localEventCount: _memoryAnalytics?.eventCount ?? 0,
          releaseFlagEnabled: releaseEnabled,
          releaseVariant: variant,
          configSource: source,
          crashlyticsAvailable: _firebaseInitialized,
          fcmMode: _fcmMode,
          errorMessage: null,
        ),
      );

      await _initializeFcm();
      _startFrameMonitor();
      _subscribeToConsentChanges();

      await _analytics.track(
        AppAnalyticsEvent.showcaseOpened(
          mode: mode.name,
          source: 'production_readiness',
        ),
      );
      await _analytics.track(
        AppAnalyticsEvent.releaseFlagEvaluated(
          result: releaseEnabled ? 'enabled' : 'disabled',
          variant: variant,
          source: source,
        ),
      );
      if (!isClosed) {
        emit(
          state.copyWith(localEventCount: _memoryAnalytics?.eventCount ?? 0),
        );
      }
    } on Object catch (error) {
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          status: ProductionReadinessStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void emitSimulatedNotification() {
    _simulationController?.emitSimulatedNotification();
    unawaited(_trackNotificationReceived());
  }

  Future<void> refreshReleaseFlag() async {
    try {
      await _remoteConfig.forceFetch();
    } on Object {
      // Keep cached/default evaluation when fetch fails.
    }
    if (isClosed) {
      return;
    }
    final bool releaseEnabled = _remoteConfig.getBool(
      RemoteConfigKeys.productionDemoEnabled,
    );
    String variant = _remoteConfig.getString(
      RemoteConfigKeys.productionDemoVariant,
    );
    if (variant.isEmpty) {
      variant = 'control';
    }
    String source = _remoteConfig.getString(RemoteConfigKeys.lastDataSource);
    if (source.isEmpty) {
      source = 'defaults';
    }
    emit(
      state.copyWith(
        releaseFlagEnabled: releaseEnabled,
        releaseVariant: variant,
        configSource: source,
      ),
    );
    await _analytics.track(
      AppAnalyticsEvent.releaseFlagEvaluated(
        result: releaseEnabled ? 'enabled' : 'disabled',
        variant: variant,
        source: source,
      ),
    );
    if (!isClosed) {
      emit(state.copyWith(localEventCount: _memoryAnalytics?.eventCount ?? 0));
    }
  }

  Future<void> setAnalyticsConsent({required final bool enabled}) async {
    await _consentRepository.save(enabled: enabled);
    await _analytics.setCollectionEnabled(enabled: enabled);
    if (isClosed) {
      return;
    }
    emit(
      state.copyWith(
        analyticsConsentEnabled: enabled,
        localEventCount: _memoryAnalytics?.eventCount ?? 0,
      ),
    );
  }

  void _subscribeToConsentChanges() {
    registerSubscription(
      _consentRepository.changes.listen((final bool enabled) {
        if (isClosed) {
          return;
        }
        unawaited(_applyExternalConsent(enabled: enabled));
      }),
    );
  }

  Future<void> _applyExternalConsent({required final bool enabled}) async {
    await _analytics.setCollectionEnabled(enabled: enabled);
    if (isClosed || state.analyticsConsentEnabled == enabled) {
      return;
    }
    emit(
      state.copyWith(
        analyticsConsentEnabled: enabled,
        localEventCount: _memoryAnalytics?.eventCount ?? 0,
      ),
    );
  }

  @override
  Future<void> close() {
    _fcmStreamsSubscribed = false;
    _frameMonitor?.stop();
    return super.close();
  }
}
