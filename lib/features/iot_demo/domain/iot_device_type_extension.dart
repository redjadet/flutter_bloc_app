import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';

/// Extension to query [IotDeviceType] capabilities.
extension IotDeviceTypeExtension on IotDeviceType {
  /// True for device types that expose a numeric value (thermostat, sensor).
  bool get hasValue =>
      this == IotDeviceType.thermostat || this == IotDeviceType.sensor;
}
