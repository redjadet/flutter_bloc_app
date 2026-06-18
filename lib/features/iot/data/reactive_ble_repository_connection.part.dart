part of 'reactive_ble_repository.dart';

mixin _ReactiveBleRepositoryConnection on _ReactiveBleRepositoryBase {
  Stream<BleConnectionPhase> watchConnection(final String deviceId) =>
      _connectionController.stream.where(
        (final phase) => phase.deviceId == deviceId,
      );

  Future<Result<void>> connect(final String deviceId) async {
    await _connectionSubscription?.cancel();
    final Completer<Result<void>> completer = Completer<Result<void>>();
    _connectionSubscription = client
        .connectToDevice(
          deviceId: deviceId,
          connectionTimeout: const Duration(seconds: 15),
        )
        .listen(
          (final update) {
            final BleConnectionPhase phase = _mapConnectionUpdate(update);
            _connectionController.add(phase);
            if (update.connectionState == DeviceConnectionState.connected &&
                !completer.isCompleted) {
              _connectedDeviceId = deviceId;
              completer.complete(const Success<void>(null));
            } else if (update.connectionState ==
                    DeviceConnectionState.disconnected &&
                update.failure != null &&
                !completer.isCompleted) {
              completer.complete(
                FailureResult<void>(
                  UnknownFailure(
                    message: 'connect_failed',
                    cause: update.failure,
                  ),
                ),
              );
            }
          },
          onError: (final Object error, final StackTrace stackTrace) {
            AppLogger.error(
              'ReactiveBleRepository connection stream',
              error,
              stackTrace,
            );
            if (!completer.isCompleted) {
              completer.complete(
                FailureResult<void>(
                  UnknownFailure(message: 'connect_failed', cause: error),
                ),
              );
            }
          },
          onDone: () {
            if (!completer.isCompleted) {
              completer.complete(
                const FailureResult<void>(
                  UnknownFailure(message: 'connect_failed'),
                ),
              );
            }
          },
        );
    return completer.future;
  }

  Future<void> disconnect() async {
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;
    final String? deviceId = _connectedDeviceId;
    _connectedDeviceId = null;
    if (deviceId != null) {
      client.clearDeviceCache(deviceId);
      _connectionController.add(
        BleConnectionPhase(
          deviceId: deviceId,
          phase: BleConnectionPhaseKind.disconnected,
        ),
      );
    }
  }

  Future<void> reconnect() async {
    final String? id = _connectedDeviceId;
    if (id == null) {
      return;
    }
    await disconnect();
    await connect(id);
  }

  BleConnectionPhase _mapConnectionUpdate(final ConnectionStateUpdate update) =>
      BleConnectionPhase(
        deviceId: update.deviceId,
        phase: switch (update.connectionState) {
          DeviceConnectionState.connecting => BleConnectionPhaseKind.connecting,
          DeviceConnectionState.connected => BleConnectionPhaseKind.connected,
          DeviceConnectionState.disconnecting =>
            BleConnectionPhaseKind.disconnecting,
          DeviceConnectionState.disconnected =>
            update.failure == null
                ? BleConnectionPhaseKind.disconnected
                : BleConnectionPhaseKind.error,
        },
        errorMessage: update.failure?.message,
      );
}
