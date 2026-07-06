import 'dart:async';
import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter_bloc_app/features/iot/data/mappers/ble_failure_mapper.dart';
import 'package:flutter_bloc_app/features/iot/data/mock_ble_device_catalog.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_adapter_status.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_connection_phase.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_discovered_device.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_repository.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_service.dart';

part 'mock_ble_repository_gatt.part.dart';
part 'mock_ble_repository_scan.part.dart';

/// Simulated BLE peripheral stack for demos and tests.
class MockBleRepository extends _MockBleRepositoryBase
    with _MockBleRepositoryScan, _MockBleRepositoryGatt
    implements BleRepository {
  MockBleRepository({
    super.timerService,
    super.random,
  });
}

class _MockBleRepositoryBase {
  _MockBleRepositoryBase({
    TimerService? timerService,
    Random? random,
  }) : _timerService = timerService ?? DefaultTimerService(),
       _random = random ?? Random() {
    _adapterController.add(
      const BleAdapterStatus(state: BleAdapterState.poweredOn),
    );
  }

  final StreamController<BleAdapterStatus> _adapterController =
      StreamController<BleAdapterStatus>.broadcast();
  final StreamController<List<BleDiscoveredDevice>> _scanController =
      StreamController<List<BleDiscoveredDevice>>.broadcast();
  final Map<String, StreamController<BleConnectionPhase>>
  _connectionControllers = <String, StreamController<BleConnectionPhase>>{};
  final Map<String, StreamController<List<int>>> _notifyControllers =
      <String, StreamController<List<int>>>{};
  final Map<String, BleDiscoveredDevice> _scanResults =
      <String, BleDiscoveredDevice>{};

  final Random _random;
  final TimerService _timerService;

  TimerDisposable? _scanTimerHandle;
  TimerDisposable? _scanTimeoutHandle;
  TimerDisposable? _notifyTimerHandle;
  String? _connectedDeviceId;
  bool _scanning = false;

  Stream<BleAdapterStatus> watchAdapterStatus() => _adapterController.stream;

  Future<Result<void>> ensureReady() async {
    _adapterController.add(
      const BleAdapterStatus(state: BleAdapterState.poweredOn),
    );
    return const Success<void>(null);
  }

  void dispose() {
    _scanning = false;
    _scanTimerHandle?.dispose();
    _scanTimerHandle = null;
    _scanTimeoutHandle?.dispose();
    _scanTimeoutHandle = null;
    _notifyTimerHandle?.dispose();
    _notifyTimerHandle = null;
    for (final StreamController<BleConnectionPhase> c
        in List<StreamController<BleConnectionPhase>>.from(
          _connectionControllers.values,
        )) {
      unawaited(c.close());
    }
    for (final StreamController<List<int>> c
        in List<StreamController<List<int>>>.from(_notifyControllers.values)) {
      unawaited(c.close());
    }
    unawaited(_adapterController.close());
    unawaited(_scanController.close());
  }

  void _driftRssi() {
    for (final MockBleDeviceProfile profile in MockBleDeviceCatalog.profiles) {
      final BleDiscoveredDevice current =
          _scanResults[profile.device.id] ?? profile.device;
      final int delta = _random.nextInt(7) - 3;
      _scanResults[profile.device.id] = current.copyWith(
        rssi: (current.rssi + delta).clamp(-95, -40),
      );
    }
  }

  void _emitScanResults() {
    if (!_scanning) {
      return;
    }
    for (final MockBleDeviceProfile profile in MockBleDeviceCatalog.profiles) {
      _scanResults.putIfAbsent(profile.device.id, () => profile.device);
    }
    final List<BleDiscoveredDevice> sorted = _scanResults.values.toList()
      ..sort((final a, final b) => b.rssi.compareTo(a.rssi));
    _scanController.add(List<BleDiscoveredDevice>.unmodifiable(sorted));
  }

  StreamController<BleConnectionPhase> _connectionController(
    final String deviceId,
  ) => _connectionControllers.putIfAbsent(
    deviceId,
    StreamController<BleConnectionPhase>.broadcast,
  );

  List<int> _readValue(final BleCharacteristicRef ref) {
    if (ref.deviceId == MockBleDeviceCatalog.thermometerId) {
      final double celsius = 36.5 + _random.nextDouble();
      final int value = (celsius * 100).round();
      return <int>[value & 0xFF, (value >> 8) & 0xFF];
    }
    if (ref.deviceId == MockBleDeviceCatalog.smartLockId &&
        ref.characteristicUuid == MockBleDeviceCatalog.lockStatusChar) {
      return <int>[0x00];
    }
    return <int>[0x64];
  }

  String _notifyKey(final BleCharacteristicRef ref) =>
      '${ref.deviceId}|${ref.serviceUuid}|${ref.characteristicUuid}';

  void _startNotifyTimerIfNeeded(final BleCharacteristicRef ref) {
    if (_notifyTimerHandle != null) {
      return;
    }
    _notifyTimerHandle = _timerService.periodic(
      const Duration(seconds: 2),
      _emitNotifySamples,
    );
  }

  void _emitNotifySamples() {
    final String? deviceId = _connectedDeviceId;
    if (deviceId == null) {
      return;
    }
    if (deviceId == MockBleDeviceCatalog.esp32Id) {
      final int humidity = 40 + _random.nextInt(20);
      final int temp = 22 + _random.nextInt(5);
      _notifyControllers[_notifyKey(
            BleCharacteristicRef(
              deviceId: deviceId,
              serviceUuid: MockBleDeviceCatalog.esp32Service,
              characteristicUuid: MockBleDeviceCatalog.esp32Char,
            ),
          )]
          ?.add(<int>[temp, humidity]);
    } else if (deviceId == MockBleDeviceCatalog.hrmId) {
      final int bpm = 60 + _random.nextInt(61);
      _notifyControllers[_notifyKey(
            BleCharacteristicRef(
              deviceId: deviceId,
              serviceUuid: MockBleDeviceCatalog.hrmService,
              characteristicUuid: MockBleDeviceCatalog.hrmChar,
            ),
          )]
          ?.add(<int>[0, bpm]);
    } else if (deviceId == MockBleDeviceCatalog.thermometerId) {
      _notifyControllers[_notifyKey(
            BleCharacteristicRef(
              deviceId: deviceId,
              serviceUuid: MockBleDeviceCatalog.thermometerService,
              characteristicUuid: MockBleDeviceCatalog.thermometerChar,
            ),
          )]
          ?.add(
            _readValue(
              BleCharacteristicRef(
                deviceId: deviceId,
                serviceUuid: MockBleDeviceCatalog.thermometerService,
                characteristicUuid: MockBleDeviceCatalog.thermometerChar,
              ),
            ),
          );
    }
  }

  StreamController<List<int>> _notifyChannelFor(
    final BleCharacteristicRef ref,
  ) => _notifyControllers.putIfAbsent(
    _notifyKey(ref),
    StreamController<List<int>>.broadcast,
  );

  void _stopNotifyTimer() {
    _notifyTimerHandle?.dispose();
    _notifyTimerHandle = null;
  }
}
