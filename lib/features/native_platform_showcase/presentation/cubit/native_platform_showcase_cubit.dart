import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_snapshot.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_status.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/platform_showcase_data.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/load_native_platform_showcase_use_case.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/watch_native_showcase_telemetry_use_case.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_platform_showcase_state.dart';

class NativePlatformShowcaseCubit extends Cubit<NativePlatformShowcaseState> {
  NativePlatformShowcaseCubit({
    required final LoadNativePlatformShowcaseUseCase loadShowcase,
    required final WatchNativeShowcaseTelemetryUseCase watchTelemetry,
  }) : this._(loadShowcase, watchTelemetry);

  NativePlatformShowcaseCubit._(this._loadShowcase, this._watchTelemetry)
    : super(const NativePlatformShowcaseState.initial());

  final LoadNativePlatformShowcaseUseCase _loadShowcase;
  final WatchNativeShowcaseTelemetryUseCase _watchTelemetry;
  bool _loadInFlight = false;
  StreamSubscription<NativeShowcaseTelemetrySnapshot>? _telemetrySubscription;
  int _lastTelemetrySequence = 0;

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

  void _startTelemetryIfNeeded() {
    if (_telemetrySubscription != null || isClosed) {
      return;
    }

    _telemetrySubscription = _watchTelemetry().listen(
      _onTelemetrySnapshot,
      onError: _onTelemetryError,
    );
  }

  void _onTelemetrySnapshot(final NativeShowcaseTelemetrySnapshot snapshot) {
    if (isClosed) {
      return;
    }

    final NativePlatformShowcaseState current = state;
    final PlatformShowcaseData? data = current.mapOrNull(loaded: (final loaded) => loaded.data);
    if (data == null) {
      return;
    }

    if (snapshot.status == NativeShowcaseTelemetryStatus.streaming &&
        snapshot.sequence <= _lastTelemetrySequence) {
      return;
    }

    if (snapshot.sequence > _lastTelemetrySequence) {
      _lastTelemetrySequence = snapshot.sequence;
    }

    emit(NativePlatformShowcaseState.loaded(data, telemetry: snapshot));
  }

  void _onTelemetryError(final Object error) {
    if (isClosed) {
      return;
    }

    final NativePlatformShowcaseState current = state;
    final loaded = current.mapOrNull(loaded: (final value) => value);
    if (loaded == null) {
      return;
    }

    final NativeShowcaseTelemetrySnapshot? previous = loaded.telemetry;
    emit(
      NativePlatformShowcaseState.loaded(
        loaded.data,
        telemetry: NativeShowcaseTelemetrySnapshot(
          status: NativeShowcaseTelemetryStatus.failed,
          sequence: _lastTelemetrySequence,
          sampleCount: previous?.sampleCount ?? 0,
          averageValue: previous?.averageValue ?? 0,
          sourceRateHz: previous?.sourceRateHz ?? 0,
          deliveredRateHz: previous?.deliveredRateHz ?? 0,
          droppedCount: previous?.droppedCount ?? 0,
          emittedAt: DateTime.now(),
          message: error.toString(),
        ),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _telemetrySubscription?.cancel();
    _telemetrySubscription = null;
    return super.close();
  }
}
