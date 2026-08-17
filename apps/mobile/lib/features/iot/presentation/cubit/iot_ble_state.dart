import 'package:flutter_bloc_app/features/iot/domain/ble_adapter_status.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_connection_phase.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_discovered_device.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_log_entry.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_service.dart';
import 'package:flutter_bloc_app/features/iot/domain/classic_bt_device.dart';
import 'package:flutter_bloc_app/features/iot/domain/iot_ble_error_code.dart';
import 'package:flutter_bloc_app/features/iot/presentation/cubit/iot_ble_connection_lifecycle.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'iot_ble_state.freezed.dart';

enum IotBleStatus { initial, loading, ready, error }

@freezed
abstract class IotBleState with _$IotBleState {
  const factory IotBleState({
    @Default(IotBleStatus.initial) IotBleStatus status,
    @Default(true) bool useMockBle,
    @Default(false) bool canToggleRealBle,
    @Default(false) bool isScanning,
    @Default(Duration(seconds: 30)) Duration scanTimeout,
    BleAdapterStatus? adapterStatus,
    @Default(<BleDiscoveredDevice>[]) List<BleDiscoveredDevice> devices,
    @Default(IotBleConnectionLifecycle.idle())
    IotBleConnectionLifecycle connectionLifecycle,
    @Default(<BleService>[]) List<BleService> services,
    BleCharacteristicRef? selectedCharacteristic,
    List<int>? lastReadValue,
    @Default(false) bool isSubscribed,
    @Default(<BleLogEntry>[]) List<BleLogEntry> logs,
    @Default(<ClassicBtDevice>[]) List<ClassicBtDevice> classicDevices,
    String? selectedClassicDeviceId,
    @Default(<ClassicBtMessage>[]) List<ClassicBtMessage> classicMessages,
    IotBleErrorCode? errorCode,
    String? errorDetail,
  }) = _IotBleState;

  const IotBleState._();

  static const int maxLogs = 200;

  bool get isReady => status == IotBleStatus.ready;

  String? get selectedDeviceId => connectionLifecycle.selectedDeviceId;

  BleConnectionPhase? get connection => connectionLifecycle.connectionPhase;

  bool get isConnected => connectionLifecycle.isConnected;

  IotBleState appendLog(BleLogEntry entry) {
    final List<BleLogEntry> next = <BleLogEntry>[...logs, entry];
    if (next.length > maxLogs) {
      next.removeRange(0, next.length - maxLogs);
    }
    return copyWith(logs: next);
  }
}
