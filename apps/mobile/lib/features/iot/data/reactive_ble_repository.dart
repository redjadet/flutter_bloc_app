import 'dart:async';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc_app/features/iot/data/ble_gatt_service_mapper.dart';
import 'package:flutter_bloc_app/features/iot/data/ble_gatt_snapshot.dart';
import 'package:flutter_bloc_app/features/iot/data/ble_radio_client.dart';
import 'package:flutter_bloc_app/features/iot/data/ble_radio_exceptions.dart';
import 'package:flutter_bloc_app/features/iot/data/mappers/ble_failure_mapper.dart';
import 'package:flutter_bloc_app/features/iot/data/noop_ble_permission_gateway.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_adapter_status.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_connection_phase.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_discovered_device.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_permission_gateway.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_repository.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_service.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart' hide Result;

part 'reactive_ble_repository_connection.part.dart';
part 'reactive_ble_repository_scan.part.dart';

/// Real BLE implementation for Android/iOS.
class ReactiveBleRepository extends _ReactiveBleRepositoryBase
    with _ReactiveBleRepositoryScan, _ReactiveBleRepositoryConnection
    implements BleRepository {
  ReactiveBleRepository({
    required super.client,
    required super.timerService,
    super.permissionGateway,
  });
}

class _ReactiveBleRepositoryBase {
  _ReactiveBleRepositoryBase({
    required this.client,
    required this.timerService,
    BlePermissionGateway? permissionGateway,
  }) : _permissionGateway =
           permissionGateway ?? const NoOpBlePermissionGateway();

  final BleRadioClient client;
  final TimerService timerService;
  final BlePermissionGateway _permissionGateway;
  final StreamController<List<BleDiscoveredDevice>> _scanController =
      StreamController<List<BleDiscoveredDevice>>.broadcast();
  final StreamController<BleConnectionPhase> _connectionController =
      StreamController<BleConnectionPhase>.broadcast();
  final Map<String, BleDiscoveredDevice> _scanResults =
      <String, BleDiscoveredDevice>{};
  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
  String? _connectedDeviceId;
  TimerDisposable? _scanTimeoutHandle;

  Stream<BleAdapterStatus> watchAdapterStatus() => client.statusStream.map(
    _mapAdapterStatus,
  );

  Future<Result<void>> ensureReady() async {
    if (client.status == BleStatus.ready) {
      return const Success<void>(null);
    }
    if (client.status == BleStatus.unauthorized) {
      final bool granted = await _permissionGateway.requestRuntimePermissions();
      if (client.status == BleStatus.ready) {
        return const Success<void>(null);
      }
      if (granted) {
        await _delay(const Duration(milliseconds: 400));
        if (client.status == BleStatus.ready) {
          return const Success<void>(null);
        }
      }
      return const FailureResult<void>(
        PermissionFailure(PermissionFailureReason.denied),
      );
    }
    if (client.status == BleStatus.poweredOff) {
      return FailureResult<void>(bluetoothDisabledFailure());
    }
    return const FailureResult<void>(
      PlatformFailure(PlatformFailureReason.unavailable),
    );
  }

  Future<Result<List<BleService>>> discoverServices() async {
    final String? id = _connectedDeviceId;
    if (id == null) {
      return const FailureResult<List<BleService>>(
        ValidationFailure('not_connected'),
      );
    }
    try {
      final List<BleGattServiceSnapshot> services = await client
          .discoverGattServices(id);
      return Success<List<BleService>>(
        mapGattSnapshotsToBleServices(services),
      );
    } on Object catch (error) {
      return FailureResult<List<BleService>>(
        UnknownFailure(message: 'discover_failed', cause: error),
      );
    }
  }

  Future<Result<List<int>>> readCharacteristic(
    final BleCharacteristicRef ref,
  ) async {
    try {
      final List<int> value = await client.readCharacteristic(ref);
      return Success<List<int>>(value);
    } on BleCharacteristicNotFoundException {
      return FailureResult<List<int>>(characteristicNotFoundFailure());
    } on Object catch (error) {
      return FailureResult<List<int>>(
        UnknownFailure(message: 'read_failed', cause: error),
      );
    }
  }

  Future<Result<void>> writeCharacteristic(
    final BleCharacteristicRef ref,
    final List<int> value, {
    final bool withoutResponse = false,
  }) async {
    try {
      await client.writeCharacteristic(
        ref,
        value,
        withoutResponse: withoutResponse,
      );
      return const Success<void>(null);
    } on BleCharacteristicNotFoundException {
      return FailureResult<void>(characteristicNotFoundFailure());
    } on Object catch (error) {
      return FailureResult<void>(
        UnknownFailure(message: 'write_failed', cause: error),
      );
    }
  }

  Stream<List<int>> subscribeCharacteristic(final BleCharacteristicRef ref) {
    try {
      return client.subscribeToCharacteristic(ref);
    } on BleCharacteristicNotFoundException {
      return Stream<List<int>>.error(characteristicNotFoundFailure());
    }
  }

  Future<void> _delay(final Duration duration) {
    if (duration <= Duration.zero) {
      return Future<void>.value();
    }
    final Completer<void> completer = Completer<void>();
    timerService.runOnce(duration, completer.complete);
    return completer.future;
  }

  BleAdapterStatus _mapAdapterStatus(final BleStatus status) =>
      BleAdapterStatus(
        state: switch (status) {
          BleStatus.unknown => BleAdapterState.unknown,
          BleStatus.unsupported => BleAdapterState.unavailable,
          BleStatus.unauthorized => BleAdapterState.unauthorized,
          BleStatus.poweredOff => BleAdapterState.poweredOff,
          BleStatus.locationServicesDisabled => BleAdapterState.unavailable,
          BleStatus.ready => BleAdapterState.poweredOn,
        },
      );

  void dispose() {
    _scanTimeoutHandle?.dispose();
    _scanTimeoutHandle = null;
    unawaited(_scanSubscription?.cancel());
    unawaited(_connectionSubscription?.cancel());
    unawaited(_scanController.close());
    unawaited(_connectionController.close());
  }
}
