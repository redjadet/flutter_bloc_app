part of 'iot_ble_cubit.dart';

mixin IotBleCubitScan on IotBleCubitCore {
  Future<void> startScan() async {
    if (state.isScanning) {
      return;
    }
    cancelScanTimeout();
    emit(state.copyWith(isScanning: true, errorCode: null, errorDetail: null));
    appendLog(
      BleLogKind.scan,
      'Starting scan (${state.scanTimeout.inSeconds}s)',
    );
    final Result<void> result = await activeRepository.startScan(
      timeout: state.scanTimeout,
    );
    if (isClosed) {
      return;
    }
    if (result case FailureResult<void>(:final failure)) {
      emit(state.copyWith(isScanning: false));
      emitBleFailure(mapFailureToIotBleErrorCode(failure), failure);
      return;
    }
    _scanTimeoutHandle = timerService.runOnce(state.scanTimeout, () {
      _scanTimeoutHandle = null;
      if (!isClosed && state.isScanning) {
        unawaited(stopScan());
      }
    });
  }

  Future<void> stopScan() async {
    if (!state.isScanning) {
      return;
    }
    cancelScanTimeout();
    await activeRepository.stopScan();
    if (isClosed) {
      return;
    }
    emit(state.copyWith(isScanning: false));
    appendLog(BleLogKind.scan, 'Scan stopped');
  }
}
