import 'package:core/core.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_adapter_status.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_connection_phase.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_discovered_device.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_service.dart';

/// BLE peripheral access — mock and reactive implementations.
abstract class BleRepository {
  Stream<BleAdapterStatus> watchAdapterStatus();

  Future<Result<void>> ensureReady();

  Future<Result<void>> startScan({Duration? timeout});

  Future<void> stopScan();

  Stream<List<BleDiscoveredDevice>> watchScanResults();

  Stream<BleConnectionPhase> watchConnection(String deviceId);

  Future<Result<void>> connect(String deviceId);

  Future<void> disconnect();

  Future<void> reconnect();

  Future<Result<List<BleService>>> discoverServices();

  Future<Result<List<int>>> readCharacteristic(BleCharacteristicRef ref);

  Future<Result<void>> writeCharacteristic(
    BleCharacteristicRef ref,
    List<int> value, {
    bool withoutResponse = false,
  });

  Stream<List<int>> subscribeCharacteristic(BleCharacteristicRef ref);
}
