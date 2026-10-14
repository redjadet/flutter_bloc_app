import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/utils/bloc/cubit_subscription_mixin.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_call_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_freshness.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_snapshot.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_status.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_stream_config.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/load_native_platform_showcase_use_case.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/share_native_showcase_text_use_case.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/trigger_native_showcase_haptic_use_case.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/watch_native_showcase_telemetry_use_case.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_platform_showcase_state.dart';
import 'package:meta/meta.dart';

part 'native_platform_showcase_cubit_telemetry.part.dart';

abstract class _NativePlatformShowcaseCubitBase
    extends Cubit<NativePlatformShowcaseState>
    with CubitSubscriptionMixin<NativePlatformShowcaseState> {
  new(
    this._loadShowcase,
    this._watchTelemetry,
    this._triggerHaptic,
    this._shareText,
    this._freshnessTracker,
    this._freshnessTickInterval,
  ) : super(const NativePlatformShowcaseState.initial());

  final LoadNativePlatformShowcaseUseCase _loadShowcase;
  final WatchNativeShowcaseTelemetryUseCase _watchTelemetry;
  final TriggerNativeShowcaseHapticUseCase _triggerHaptic;
  final ShareNativeShowcaseTextUseCase _shareText;
  final NativeShowcaseTelemetryFreshnessTracker _freshnessTracker;
  final Duration _freshnessTickInterval;
  bool _loadInFlight = false;
  // ignore: cancel_subscriptions - Managed by CubitSubscriptionMixin.
  StreamSubscription<NativeShowcaseTelemetrySnapshot>? _telemetrySubscription;
  Timer? _freshnessTimer;
  int _lastTelemetrySequence = 0;
}

class NativePlatformShowcaseCubit extends _NativePlatformShowcaseCubitBase
    with _NativePlatformShowcaseCubitTelemetry {
  new({
    required LoadNativePlatformShowcaseUseCase loadShowcase,
    required WatchNativeShowcaseTelemetryUseCase watchTelemetry,
    required TriggerNativeShowcaseHapticUseCase triggerHaptic,
    required ShareNativeShowcaseTextUseCase shareText,
    NativeShowcaseTelemetryFreshnessTracker? freshnessTracker,
    @visibleForTesting
    Duration freshnessTickInterval =
        NativeShowcaseTelemetryFreshnessTracker.tickInterval,
  }) : super(
         loadShowcase,
         watchTelemetry,
         triggerHaptic,
         shareText,
         freshnessTracker ?? NativeShowcaseTelemetryFreshnessTracker(),
         freshnessTickInterval,
       );

  Future<void> load() async {
    if (isClosed || _loadInFlight) return;
    _loadInFlight = true;
    emit(const NativePlatformShowcaseState.loading());
    try {
      final data = await _loadShowcase();
      if (isClosed) return;
      emit(NativePlatformShowcaseState.loaded(data));
      _startTelemetryIfNeeded();
    } on Object {
      if (isClosed) return;
      emit(
        const NativePlatformShowcaseState.error(
          failure: NativePlatformShowcaseFailureKind.loadFailed,
        ),
      );
    } finally {
      _loadInFlight = false;
    }
  }

  Future<void> triggerHaptic() =>
      _runAction(NativePlatformShowcaseAction.haptic, () => _triggerHaptic());

  Future<void> shareDemoText(String text) =>
      _runAction(NativePlatformShowcaseAction.share, () => _shareText(text));

  Future<void> _runAction(
    NativePlatformShowcaseAction action,
    Future<NativeInteropCallResult> Function() invoke,
  ) async {
    if (isClosed) {
      return;
    }

    final loaded = state.mapOrNull(loaded: (value) => value);
    if (loaded == null || loaded.actionInFlight != null) {
      return;
    }

    emit(
      NativePlatformShowcaseState.loaded(
        loaded.data,
        telemetry: loaded.telemetry,
        telemetryFreshness: loaded.telemetryFreshness,
        lastAction: loaded.lastAction,
        lastActionResult: loaded.lastActionResult,
        actionInFlight: action,
      ),
    );

    final NativeInteropCallResult result = await invoke();
    if (isClosed) {
      return;
    }

    final current = state.mapOrNull(loaded: (value) => value);
    if (current == null) {
      return;
    }

    emit(
      NativePlatformShowcaseState.loaded(
        current.data,
        telemetry: current.telemetry,
        telemetryFreshness: current.telemetryFreshness,
        lastAction: action,
        lastActionResult: result,
      ),
    );
  }

  @override
  Future<void> close() async {
    _freshnessTimer?.cancel();
    _freshnessTimer = null;
    _telemetrySubscription = null;
    return await super.close();
  }
}
