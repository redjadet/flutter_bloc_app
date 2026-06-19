import 'package:flutter_bloc_app/features/iot/domain/entities/ble_connection_phase.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'iot_ble_connection_lifecycle.freezed.dart';

/// Connection lifecycle slice grouped on BLE cubit state (phase 1).
@freezed
sealed class IotBleConnectionLifecycle with _$IotBleConnectionLifecycle {
  const factory IotBleConnectionLifecycle.idle({
    final String? selectedDeviceId,
  }) = IotBleConnectionIdle;

  const factory IotBleConnectionLifecycle.active(
    final BleConnectionPhase phase,
  ) = IotBleConnectionActive;

  const IotBleConnectionLifecycle._();

  String? get selectedDeviceId => switch (this) {
    IotBleConnectionIdle(:final selectedDeviceId) => selectedDeviceId,
    IotBleConnectionActive(:final phase) => phase.deviceId,
  };

  BleConnectionPhase? get connectionPhase => switch (this) {
    IotBleConnectionActive(:final phase) => phase,
    IotBleConnectionIdle() => null,
  };

  bool get isConnected =>
      connectionPhase?.phase == BleConnectionPhaseKind.connected;
}
