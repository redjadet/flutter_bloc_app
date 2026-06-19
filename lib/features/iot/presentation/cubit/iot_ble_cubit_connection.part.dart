part of 'iot_ble_cubit.dart';

mixin IotBleCubitConnection on IotBleCubitCore {
  Future<void> connectSelected() async {
    final String? deviceId = state.selectedDeviceId;
    if (deviceId == null) {
      return;
    }
    await connect(deviceId);
  }

  Future<void> connect(final String deviceId) async {
    if (state.isScanning) {
      await activeRepository.stopScan();
      if (isClosed) {
        return;
      }
      emit(state.copyWith(isScanning: false));
    }
    emit(
      state.copyWith(
        connectionLifecycle: IotBleConnectionLifecycle.idle(
          selectedDeviceId: deviceId,
        ),
        errorCode: null,
      ),
    );
    await cancelConnectionSubscription();
    _connectionSubscription = registerSubscription(
      activeRepository
          .watchConnection(deviceId)
          .listen(
            (final phase) {
              if (isClosed) {
                return;
              }
              emit(
                state.copyWith(
                  connectionLifecycle: IotBleConnectionLifecycle.active(phase),
                ),
              );
            },
            onError: (final Object error, final StackTrace stackTrace) {
              AppLogger.error(
                'IotBleCubit connection stream',
                error,
                stackTrace,
              );
            },
          ),
    );
    appendLog(BleLogKind.connect, 'Connecting to $deviceId');
    final Result<List<BleService>> result = await sessionCoordinator
        .connectAndDiscover(deviceId);
    if (isClosed) {
      return;
    }
    if (result case FailureResult<List<BleService>>(:final failure)) {
      emitBleFailure(mapFailureToIotBleErrorCode(failure), failure);
      return;
    }
    if (result case Success<List<BleService>>(:final value)) {
      emit(
        state.copyWith(
          services: value,
          status: IotBleStatus.ready,
          errorCode: null,
          errorDetail: null,
        ),
      );
      appendLog(
        BleLogKind.connect,
        'Connected and discovered ${value.length} services',
      );
    }
  }

  Future<void> disconnect() async {
    appendLog(BleLogKind.disconnect, 'Disconnecting');
    await sessionCoordinator.teardown();
    if (isClosed) {
      return;
    }
    emit(
      state.copyWith(
        connectionLifecycle: IotBleConnectionLifecycle.idle(
          selectedDeviceId: state.selectedDeviceId,
        ),
        services: const <BleService>[],
        selectedCharacteristic: null,
        lastReadValue: null,
        isSubscribed: false,
      ),
    );
  }

  Future<void> reconnect() async {
    final Result<void> result = await sessionCoordinator.reconnect();
    if (isClosed) {
      return;
    }
    if (result case FailureResult<void>(:final failure)) {
      emitBleFailure(mapFailureToIotBleErrorCode(failure), failure);
      return;
    }
    final Result<List<BleService>> services = await activeRepository
        .discoverServices();
    if (isClosed) {
      return;
    }
    if (services case FailureResult<List<BleService>>(:final failure)) {
      emitBleFailure(mapFailureToIotBleErrorCode(failure), failure);
      return;
    }
    if (services case Success<List<BleService>>(:final value)) {
      emit(
        state.copyWith(
          services: value,
          status: IotBleStatus.ready,
          errorCode: null,
          errorDetail: null,
        ),
      );
      appendLog(
        BleLogKind.connect,
        'Reconnected and discovered ${value.length} services',
      );
    }
  }
}
