import 'package:freezed_annotation/freezed_annotation.dart';

part 'iot_device_command.freezed.dart';

/// Command that can be sent to an IoT device in the demo.
@freezed
sealed class IotDeviceCommand with _$IotDeviceCommand {
  const factory IotDeviceCommand.toggle() = IotDeviceCommandToggle;

  const factory IotDeviceCommand.setValue(final num value) =
      IotDeviceCommandSetValue;
}
