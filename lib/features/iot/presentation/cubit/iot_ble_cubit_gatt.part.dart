part of 'iot_ble_cubit.dart';

mixin IotBleCubitGatt on IotBleCubitCore {
  Future<void> readSelectedCharacteristic() async {
    final BleCharacteristicRef? ref = state.selectedCharacteristic;
    if (ref == null) {
      return;
    }
    final Result<List<int>> result = await activeRepository.readCharacteristic(
      ref,
    );
    if (isClosed) {
      return;
    }
    if (result case FailureResult<List<int>>(:final failure)) {
      emitBleFailure(mapFailureToIotBleErrorCode(failure), failure);
      return;
    }
    if (result case Success<List<int>>(:final value)) {
      emit(state.copyWith(lastReadValue: value));
      appendLog(BleLogKind.read, 'Read ${value.length} bytes');
    }
  }

  Future<void> writeSelectedCharacteristic(
    final List<int> value, {
    final bool withoutResponse = false,
  }) async {
    final BleCharacteristicRef? ref = state.selectedCharacteristic;
    if (ref == null) {
      return;
    }
    final Result<void> result = await activeRepository.writeCharacteristic(
      ref,
      value,
      withoutResponse: withoutResponse,
    );
    if (isClosed) {
      return;
    }
    if (result case FailureResult<void>(:final failure)) {
      emitBleFailure(mapFailureToIotBleErrorCode(failure), failure);
      return;
    }
    appendLog(
      BleLogKind.write,
      'Wrote ${value.length} bytes${withoutResponse ? ' (no response)' : ''}',
    );
  }

  Future<void> subscribeSelectedCharacteristic() async {
    final BleCharacteristicRef? ref = state.selectedCharacteristic;
    if (ref == null) {
      return;
    }
    await cancelNotifySubscription();
    _notifySubscription = registerSubscription(
      activeRepository
          .subscribeCharacteristic(ref)
          .listen(
            (final value) {
              if (isClosed) {
                return;
              }
              emit(
                state.copyWith(
                  lastReadValue: value,
                  isSubscribed: true,
                ),
              );
              appendLog(BleLogKind.notify, 'Notify ${value.length} bytes');
            },
            onError: (final Object error, final StackTrace stackTrace) {
              AppLogger.error('IotBleCubit notify stream', error, stackTrace);
              emitBleFailure(IotBleErrorCode.subscribe, error);
            },
          ),
    );
    if (isClosed) {
      return;
    }
    emit(state.copyWith(isSubscribed: true));
    appendLog(BleLogKind.notify, 'Subscribed to ${ref.characteristicUuid}');
  }

  Future<void> connectClassicDevice(final String deviceId) async {
    final Result<void> result = await classicRepository.connect(deviceId);
    if (isClosed) {
      return;
    }
    if (result case FailureResult<void>(:final failure)) {
      emitBleFailure(mapFailureToIotBleErrorCode(failure), failure);
      return;
    }
    emit(state.copyWith(selectedClassicDeviceId: deviceId));
    await cancelClassicMessageSubscription();
    _classicMessageSubscription = registerSubscription(
      classicRepository
          .watchIncoming(deviceId)
          .listen(
            (final message) {
              if (isClosed) {
                return;
              }
              emit(
                state.copyWith(
                  classicMessages: <ClassicBtMessage>[
                    ...state.classicMessages,
                    message,
                  ],
                ),
              );
            },
            onError: (final Object error, final StackTrace stackTrace) {
              AppLogger.error(
                'IotBleCubit classic message stream',
                error,
                stackTrace,
              );
            },
          ),
    );
  }

  Future<void> sendClassicMessage(final String text) async {
    final String? deviceId = state.selectedClassicDeviceId;
    if (deviceId == null || text.trim().isEmpty) {
      return;
    }
    final Result<void> result = await classicRepository.send(deviceId, text);
    if (isClosed) {
      return;
    }
    if (result case FailureResult<void>(:final failure)) {
      emitBleFailure(mapFailureToIotBleErrorCode(failure), failure);
      return;
    }
    emit(
      state.copyWith(
        classicMessages: <ClassicBtMessage>[
          ...state.classicMessages,
          ClassicBtMessage(
            direction: ClassicBtMessageDirection.outgoing,
            text: text,
            timestamp: DateTime.now(),
          ),
        ],
      ),
    );
  }
}
