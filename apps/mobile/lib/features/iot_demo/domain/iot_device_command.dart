import 'package:freezed_annotation/freezed_annotation.dart';

part 'iot_device_command.freezed.dart';

/// Command that can be sent to an IoT device in the demo.
@freezed
sealed class IotDeviceCommand with _$IotDeviceCommand {
  const factory toggle() = IotDeviceCommandToggle;

  const factory setValue(num value) = IotDeviceCommandSetValue;
}
