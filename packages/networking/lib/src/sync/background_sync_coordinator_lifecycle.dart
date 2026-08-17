part of 'background_sync_coordinator.dart';

extension on BackgroundSyncCoordinator {
  Future<void> _bindSyncListeners() async {
    await _cancelNetworkSubscription();
    _networkSubscription = _networkStatusService.statusStream.listen(
      _handleNetworkStatusChanged,
      onError: (Object error, StackTrace stackTrace) {
        _handleListenerError(
          logContext: 'BackgroundSyncCoordinator.networkSubscription failed',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    _syncIntervalHandle = _timerService.periodic(
      _syncInterval,
      () => unawaited(_triggerSync(immediate: false)),
    );
    _timerHandles.register(_syncIntervalHandle);

    await _cancelEnqueueSubscription();
    _enqueueSubscription = _repository.onOperationEnqueued.listen(
      (_) => unawaited(_triggerSync(immediate: true)),
      onError: (Object error, StackTrace stackTrace) {
        _handleListenerError(
          logContext: 'BackgroundSyncCoordinator.enqueueSubscription failed',
          error: error,
          stackTrace: stackTrace,
        );
      },
      cancelOnError: false,
    );

    _startIotDemoRealtimeSubscription?.call(_requestImmediateSync);
  }

  Future<void> _unbindSyncListeners() async {
    _disposeSyncIntervalHandle();
    await _cancelEnqueueSubscription();
    _stopIotDemoRealtimeSubscription?.call();
    await _cancelNetworkSubscription();
  }

  void _handleNetworkStatusChanged(NetworkStatus status) {
    if (status == NetworkStatus.online) {
      _requestImmediateSync();
    }
  }

  void _requestImmediateSync() {
    unawaited(_triggerSync(immediate: true));
  }

  void _handleListenerError({
    required String logContext,
    required Object error,
    required StackTrace stackTrace,
  }) {
    AppLogger.error(logContext, error, stackTrace);
    _emit(SyncStatus.degraded);
  }

  void _disposeSyncIntervalHandle() {
    _syncIntervalHandle?.dispose();
    _timerHandles.unregister(_syncIntervalHandle);
    _syncIntervalHandle = null;
  }

  Future<void> _cancelNetworkSubscription() async {
    await _networkSubscription?.cancel();
    _networkSubscription = null;
  }

  Future<void> _cancelEnqueueSubscription() async {
    await _enqueueSubscription?.cancel();
    _enqueueSubscription = null;
  }

  Future<void> _awaitInFlightSync(Future<void>? inFlight) async {
    if (inFlight == null) {
      return;
    }
    try {
      await inFlight;
    } on Exception {
      // Ignore errors from in-flight sync during shutdown.
    }
  }
}
