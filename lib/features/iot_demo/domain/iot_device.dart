import 'package:freezed_annotation/freezed_annotation.dart';

part 'iot_device.freezed.dart';
part 'iot_device.g.dart';

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
    required final String id,
    required final String name,
    required final IotDeviceType type,
    final DateTime? lastSeen,
    @Default(IotConnectionState.disconnected)
    final IotConnectionState connectionState,
    @Default(false) final bool toggledOn,
    @Default(0.0) final double value,
  }) = _IotDevice;

  factory IotDevice.fromJson(final Map<String, dynamic> json) =>
      _$IotDeviceFromJson(json);

  const IotDevice._();
}
