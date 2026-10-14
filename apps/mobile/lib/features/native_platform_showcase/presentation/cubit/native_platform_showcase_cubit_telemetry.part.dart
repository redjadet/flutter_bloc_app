// Telemetry helpers share Cubit internals from the owning library.
// ignore_for_file: invalid_use_of_protected_member

part of 'native_platform_showcase_cubit.dart';

extension _NativePlatformShowcaseCubitTelemetry on NativePlatformShowcaseCubit {
  void _startTelemetryIfNeeded() {
    if (_telemetrySubscription != null || isClosed) {
      return;
    }

    final NativeShowcaseTelemetryStreamConfig config =
        NativeShowcaseTelemetryStreamConfig.renderDefault(
          sessionId: 'showcase-${DateTime.now().microsecondsSinceEpoch}',
        );

    _telemetrySubscription = registerSubscription(
      _watchTelemetry(config: config).listen(
        _onTelemetrySnapshot,
        onError: _onTelemetryError,
      ),
    );
    _freshnessTimer ??= Timer.periodic(
      _freshnessTickInterval,
      (_) => _emitFreshnessIfChanged(),
    );
  }

  void _onTelemetrySnapshot(NativeShowcaseTelemetrySnapshot snapshot) {
    if (isClosed) {
      return;
    }

    final loaded = state.mapOrNull(loaded: (value) => value);
    if (loaded == null) {
      return;
    }

    if (snapshot.status == NativeShowcaseTelemetryStatus.streaming &&
        snapshot.sequence <= _lastTelemetrySequence) {
      return;
    }

    if (snapshot.sequence > _lastTelemetrySequence) {
      _lastTelemetrySequence = snapshot.sequence;
    }

    final NativeShowcaseTelemetrySnapshot displaySnapshot = _displaySnapshot(
      previous: loaded.telemetry,
      incoming: snapshot,
    );
    final NativeShowcaseTelemetryFreshness? freshness =
        snapshot.status == NativeShowcaseTelemetryStatus.streaming
        ? _freshnessTracker.onSnapshot(snapshot)
        : loaded.telemetryFreshness;

    emit(
      NativePlatformShowcaseState.loaded(
        loaded.data,
        telemetry: displaySnapshot,
        telemetryFreshness: freshness,
        lastAction: loaded.lastAction,
        lastActionResult: loaded.lastActionResult,
        actionInFlight: loaded.actionInFlight,
      ),
    );
  }

  /// Liveness ticks (`acceptedCount == 0`) refresh receipt age only; keep the
  /// last accepted average on screen so update rate and value age stay distinct.
  NativeShowcaseTelemetrySnapshot _displaySnapshot({
    required NativeShowcaseTelemetrySnapshot? previous,
    required NativeShowcaseTelemetrySnapshot incoming,
  }) {
    if (incoming.status != NativeShowcaseTelemetryStatus.streaming ||
        incoming.acceptedCount > 0 ||
        previous == null ||
        previous.status != NativeShowcaseTelemetryStatus.streaming) {
      return incoming;
    }

    return incoming.copyWith(averageValue: previous.averageValue);
  }

  void _emitFreshnessIfChanged() {
    if (isClosed) {
      return;
    }

    final loaded = state.mapOrNull(loaded: (value) => value);
    if (loaded == null || loaded.telemetry == null) {
      return;
    }

    final NativeShowcaseTelemetryFreshness? next = _freshnessTracker.evaluate();
    if (next == null || next == loaded.telemetryFreshness) {
      return;
    }

    emit(
      NativePlatformShowcaseState.loaded(
        loaded.data,
        telemetry: loaded.telemetry,
        telemetryFreshness: next,
        lastAction: loaded.lastAction,
        lastActionResult: loaded.lastActionResult,
        actionInFlight: loaded.actionInFlight,
      ),
    );
  }

  void _onTelemetryError(Object error) {
    if (isClosed) {
      return;
    }

    final loaded = state.mapOrNull(loaded: (value) => value);
    if (loaded == null) {
      return;
    }

    final NativeShowcaseTelemetrySnapshot? previous = loaded.telemetry;
    emit(
      NativePlatformShowcaseState.loaded(
        loaded.data,
        telemetry: NativeShowcaseTelemetrySnapshot(
          status: NativeShowcaseTelemetryStatus.failed,
          schemaVersion:
              previous?.schemaVersion ??
              NativeShowcaseTelemetryStreamConfig.supportedSchemaVersion,
          sessionId: previous?.sessionId ?? '',
          sequence: _lastTelemetrySequence,
          acceptedCount: previous?.acceptedCount ?? 0,
          sourceReceivedCount: previous?.sourceReceivedCount ?? 0,
          averageValue: previous?.averageValue ?? 0,
          sourceRateHz: previous?.sourceRateHz ?? 0,
          deliveredRateHz: previous?.deliveredRateHz ?? 0,
          droppedBeforeBridgeCount: previous?.droppedBeforeBridgeCount ?? 0,
          windowStartedAt: previous?.windowStartedAt ?? DateTime.now(),
          emittedAt: DateTime.now(),
          message: error.toString(),
        ),
        telemetryFreshness: loaded.telemetryFreshness,
        lastAction: loaded.lastAction,
        lastActionResult: loaded.lastActionResult,
        actionInFlight: loaded.actionInFlight,
      ),
    );
  }
}
