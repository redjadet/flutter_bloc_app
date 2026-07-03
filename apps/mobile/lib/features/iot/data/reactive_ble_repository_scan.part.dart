part of 'reactive_ble_repository.dart';

mixin _ReactiveBleRepositoryScan on _ReactiveBleRepositoryBase {
  Future<Result<void>> startScan({final Duration? timeout}) async {
    await _scanSubscription?.cancel();
    _scanResults.clear();
    _scanSubscription = client
        .scanForDevices(withServices: const <Uuid>[])
        .listen(
          (final device) {
            _scanResults[device.id] = BleDiscoveredDevice(
              id: device.id,
              name: device.name.isEmpty ? 'Unknown' : device.name,
              rssi: device.rssi,
              connectable: device.connectable == Connectable.available,
            );
            _scanController.add(
              List<BleDiscoveredDevice>.unmodifiable(_scanResults.values),
            );
          },
          onError: (_) {
            _scanController.addError(
              const UnknownFailure(message: 'scan_failed'),
            );
          },
        );
    if (timeout != null) {
      _scanTimeoutHandle?.dispose();
      _scanTimeoutHandle = timerService.runOnce(timeout, () {
        unawaited(stopScan());
      });
    }
    return const Success<void>(null);
  }

  Future<void> stopScan() async {
    _scanTimeoutHandle?.dispose();
    _scanTimeoutHandle = null;
    await _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  Stream<List<BleDiscoveredDevice>> watchScanResults() =>
      _scanController.stream;
}
