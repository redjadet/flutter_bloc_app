import 'package:core/core.dart';
import 'package:flutter_bloc_app/features/iot/data/mappers/ble_failure_mapper.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_adapter_status.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_connection_phase.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_discovered_device.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_repository.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_service.dart';

/// Phase 1 stub when real BLE selected off-mobile.
class UnsupportedBleRepository implements BleRepository {
  const UnsupportedBleRepository();

  @override
  Stream<BleAdapterStatus> watchAdapterStatus() =>
      Stream<BleAdapterStatus>.value(
        const BleAdapterStatus(
          state: BleAdapterState.unavailable,
          message: 'Real BLE unavailable on this platform',
        ),
      );

  @override
  Future<Result<void>> ensureReady() async =>
      FailureResult<void>(unsupportedPlatformFailure());

  @override
  Future<Result<void>> startScan({final Duration? timeout}) async =>
      FailureResult<void>(unsupportedPlatformFailure());

  @override
  Future<void> stopScan() async {}

  @override
  Stream<List<BleDiscoveredDevice>> watchScanResults() =>
      const Stream<List<BleDiscoveredDevice>>.empty();

  @override
  Stream<BleConnectionPhase> watchConnection(final String deviceId) =>
      Stream<BleConnectionPhase>.value(
        BleConnectionPhase(
          deviceId: deviceId,
          phase: BleConnectionPhaseKind.disconnected,
        ),
      );

  @override
  Future<Result<void>> connect(final String deviceId) async =>
      FailureResult<void>(unsupportedPlatformFailure());

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> reconnect() async {}

  @override
  Future<Result<List<BleService>>> discoverServices() async =>
      FailureResult<List<BleService>>(unsupportedPlatformFailure());

  @override
  Future<Result<List<int>>> readCharacteristic(
    final BleCharacteristicRef ref,
  ) async => FailureResult<List<int>>(unsupportedPlatformFailure());

  @override
  Future<Result<void>> writeCharacteristic(
    final BleCharacteristicRef ref,
    final List<int> value, {
    final bool withoutResponse = false,
  }) async => FailureResult<void>(unsupportedPlatformFailure());

  @override
  Stream<List<int>> subscribeCharacteristic(final BleCharacteristicRef ref) =>
      const Stream<List<int>>.empty();
}
