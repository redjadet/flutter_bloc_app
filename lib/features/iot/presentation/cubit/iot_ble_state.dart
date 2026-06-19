import 'package:flutter_bloc_app/features/iot/domain/entities/ble_adapter_status.dart';
import 'package:flutter_bloc_app/features/iot/domain/entities/ble_connection_phase.dart';
import 'package:flutter_bloc_app/features/iot/domain/entities/ble_discovered_device.dart';
import 'package:flutter_bloc_app/features/iot/domain/entities/ble_log_entry.dart';
import 'package:flutter_bloc_app/features/iot/domain/entities/ble_service.dart';
import 'package:flutter_bloc_app/features/iot/domain/entities/classic_bt_device.dart';
import 'package:flutter_bloc_app/features/iot/domain/iot_ble_error_code.dart';
import 'package:flutter_bloc_app/features/iot/presentation/cubit/iot_ble_connection_lifecycle.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'iot_ble_state.freezed.dart';

enum IotBleStatus { initial, loading, ready, error }

@freezed
abstract class IotBleState with _$IotBleState {
  const factory IotBleState({
    @Default(IotBleStatus.initial) final IotBleStatus status,
    @Default(true) final bool useMockBle,
    @Default(false) final bool canToggleRealBle,
    @Default(false) final bool isScanning,
    @Default(Duration(seconds: 30)) final Duration scanTimeout,
    final BleAdapterStatus? adapterStatus,
    @Default(<BleDiscoveredDevice>[]) final List<BleDiscoveredDevice> devices,
    @Default(IotBleConnectionLifecycle.idle())
    final IotBleConnectionLifecycle connectionLifecycle,
    @Default(<BleService>[]) final List<BleService> services,
    final BleCharacteristicRef? selectedCharacteristic,
    final List<int>? lastReadValue,
    @Default(false) final bool isSubscribed,
    @Default(<BleLogEntry>[]) final List<BleLogEntry> logs,
    @Default(<ClassicBtDevice>[]) final List<ClassicBtDevice> classicDevices,
    final String? selectedClassicDeviceId,
    @Default(<ClassicBtMessage>[]) final List<ClassicBtMessage> classicMessages,
    final IotBleErrorCode? errorCode,
    final String? errorDetail,
  }) = _IotBleState;

  const IotBleState._();

  static const int maxLogs = 200;

  bool get isReady => status == IotBleStatus.ready;

  String? get selectedDeviceId => connectionLifecycle.selectedDeviceId;

  BleConnectionPhase? get connection => connectionLifecycle.connectionPhase;

  bool get isConnected => connectionLifecycle.isConnected;

  IotBleState appendLog(final BleLogEntry entry) {
    final List<BleLogEntry> next = <BleLogEntry>[...logs, entry];
    if (next.length > maxLogs) {
      next.removeRange(0, next.length - maxLogs);
    }
    return copyWith(logs: next);
  }
}
