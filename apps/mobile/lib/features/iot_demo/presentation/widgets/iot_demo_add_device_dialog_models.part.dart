part of 'iot_demo_add_device_dialog.dart';

/// Result of the add device dialog: name, type, and optional initial value.
class IotDemoAddDeviceResult {
  const IotDemoAddDeviceResult({
    required this.name,
    required this.type,
    this.initialValue = 0,
  });

  final String name;
  final IotDeviceType type;
  final double initialValue;
}
