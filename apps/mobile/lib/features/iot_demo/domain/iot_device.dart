import 'package:freezed_annotation/freezed_annotation.dart';

part 'iot_device.freezed.dart';

/// Connection state of an IoT device.
enum IotConnectionState {
  disconnected,
  connecting,
  connected,
}

/// Type of IoT device for demo display.
enum IotDeviceType {
  light,
  sensor,
  switch_,
  thermostat,
  plug,
}

/// Domain model for a simulated IoT device.
@freezed
abstract class IotDevice with _$IotDevice {
  const factory IotDevice({
    required String id,
    required String name,
    required IotDeviceType type,
    DateTime? lastSeen,
    @Default(IotConnectionState.disconnected)
    IotConnectionState connectionState,
    @Default(false) bool toggledOn,
    @Default(0.0) double value,
  }) = _IotDevice;

  const IotDevice._();
}
