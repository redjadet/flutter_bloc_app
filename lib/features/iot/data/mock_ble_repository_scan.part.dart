part of 'mock_ble_repository.dart';

mixin _MockBleRepositoryScan on _MockBleRepositoryBase {
  Stream<List<BleDiscoveredDevice>> watchScanResults() =>
      _scanController.stream;

  Future<Result<void>> startScan({final Duration? timeout}) async {
    if (_scanning) {
      return const Success<void>(null);
    }
    _scanning = true;
    _scanResults.clear();
    _emitScanResults();
    _scanTimerHandle?.dispose();
    _scanTimerHandle = _timerService.periodic(
      const Duration(milliseconds: 800),
      () {
        _driftRssi();
        _emitScanResults();
      },
    );
    if (timeout != null) {
      _scanTimeoutHandle?.dispose();
      _scanTimeoutHandle = _timerService.runOnce(timeout, () {
        unawaited(stopScan());
      });
    }
    return const Success<void>(null);
  }

  Future<void> stopScan() async {
    _scanning = false;
    _scanTimerHandle?.dispose();
    _scanTimerHandle = null;
    _scanTimeoutHandle?.dispose();
    _scanTimeoutHandle = null;
  }

  Stream<BleConnectionPhase> watchConnection(final String deviceId) {
    return _connectionController(deviceId).stream;
  }

  Future<Result<void>> connect(final String deviceId) async {
    if (MockBleDeviceCatalog.profileForId(deviceId) == null) {
      return const FailureResult<void>(
        UnknownFailure(message: 'device_not_found'),
      );
    }
    _connectionController(deviceId).add(
      BleConnectionPhase(
        deviceId: deviceId,
        phase: BleConnectionPhaseKind.connecting,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 450));
    _connectedDeviceId = deviceId;
    _connectionController(deviceId).add(
      BleConnectionPhase(
        deviceId: deviceId,
        phase: BleConnectionPhaseKind.connected,
      ),
    );
    return const Success<void>(null);
  }

  Future<void> disconnect() async {
    final String? deviceId = _connectedDeviceId;
    _stopNotifyTimer();
    if (deviceId != null) {
      _connectionController(deviceId).add(
        BleConnectionPhase(
          deviceId: deviceId,
          phase: BleConnectionPhaseKind.disconnected,
        ),
      );
    }
    _connectedDeviceId = null;
  }

  Future<void> reconnect() async {
    final String? deviceId = _connectedDeviceId;
    if (deviceId == null) {
      return;
    }
    await disconnect();
    await connect(deviceId);
  }
}
