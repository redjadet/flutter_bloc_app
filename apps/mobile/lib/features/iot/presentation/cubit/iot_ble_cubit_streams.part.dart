part of 'iot_ble_cubit.dart';

mixin IotBleCubitStreams on IotBleCubitCore {
  Future<void> initialize() async {
    if (state.status == IotBleStatus.loading) {
      return;
    }
    emit(
      state.copyWith(
        status: IotBleStatus.loading,
        errorCode: null,
        errorDetail: null,
      ),
    );
    bindAdapterStream();
    bindScanStream();
    bindClassicStream();
    final Result<void> ready = await activeRepository.ensureReady();
    if (isClosed) {
      return;
    }
    if (ready case FailureResult<void>(:final failure)) {
      emitBleFailure(mapFailureToIotBleErrorCode(failure), failure);
      return;
    }
    emit(
      state.copyWith(
        status: IotBleStatus.ready,
        errorCode: null,
        errorDetail: null,
      ),
    );
    appendLog(
      BleLogKind.info,
      'BLE showcase ready (${state.useMockBle ? 'mock' : 'real'})',
    );
  }

  Future<void> toggleBleMode({required final bool useMock}) async {
    if (!state.canToggleRealBle && !useMock) {
      return;
    }
    if (state.useMockBle == useMock) {
      return;
    }
    await teardownActiveSession();
    if (isClosed) {
      return;
    }
    emit(
      state.copyWith(
        useMockBle: useMock,
        devices: const <BleDiscoveredDevice>[],
        connectionLifecycle: const IotBleConnectionLifecycle.idle(),
        services: const <BleService>[],
        selectedCharacteristic: null,
        lastReadValue: null,
        isSubscribed: false,
        isScanning: false,
        errorCode: null,
        errorDetail: null,
      ),
    );
    resubscribeRepositoryStreams();
    await initialize();
  }

  /// Retry after a full-screen BLE error. Unsupported real mode falls back to mock.
  Future<void> recoverFromBleError() async {
    if (!state.useMockBle &&
        state.errorCode == IotBleErrorCode.unsupportedPlatform) {
      await toggleBleMode(useMock: true);
      return;
    }
    await initialize();
  }

  @override
  Future<void> close() async {
    await teardownActiveSession();
    await classicRepository.disconnect();
    await _adapterSubscription?.cancel();
    _adapterSubscription = null;
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    await _classicSubscription?.cancel();
    _classicSubscription = null;
    await cancelClassicMessageSubscription();
    return super.close();
  }

  void bindAdapterStream() {
    unawaited(_adapterSubscription?.cancel());
    final StreamSubscription<BleAdapterStatus> subscription =
        _adapterSubscription = activeRepository.watchAdapterStatus().listen(
          (final status) {
            if (isClosed) {
              return;
            }
            emit(state.copyWith(adapterStatus: status));
          },
          onError: (final Object error, final StackTrace stackTrace) {
            AppLogger.error('IotBleCubit adapter stream', error, stackTrace);
          },
        );
    registerSubscription(subscription);
  }

  void bindScanStream() {
    unawaited(_scanSubscription?.cancel());
    final StreamSubscription<List<BleDiscoveredDevice>> subscription =
        _scanSubscription = activeRepository.watchScanResults().listen(
          (final devices) {
            if (isClosed) {
              return;
            }
            emit(state.copyWith(devices: devices));
          },
          onError: (final Object error, final StackTrace stackTrace) {
            AppLogger.error('IotBleCubit scan stream', error, stackTrace);
          },
        );
    registerSubscription(subscription);
  }

  void bindClassicStream() {
    unawaited(_classicSubscription?.cancel());
    final StreamSubscription<List<ClassicBtDevice>> subscription =
        _classicSubscription = classicRepository.watchPairedDevices().listen(
          (final devices) {
            if (isClosed) {
              return;
            }
            emit(state.copyWith(classicDevices: devices));
          },
          onError: (final Object error, final StackTrace stackTrace) {
            AppLogger.error('IotBleCubit classic stream', error, stackTrace);
          },
        );
    registerSubscription(subscription);
  }

  void resubscribeRepositoryStreams() {
    unawaited(_connectionSubscription?.cancel());
    _connectionSubscription = null;
    bindAdapterStream();
    bindScanStream();
  }

  Future<void> teardownActiveSession() async {
    await cancelNotifySubscription();
    await cancelConnectionSubscription();
    cancelScanTimeout();
    await sessionCoordinator.teardown();
    await activeRepository.stopScan();
  }
}
