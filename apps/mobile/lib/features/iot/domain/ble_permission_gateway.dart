/// Runtime BLE permission escalation (Android 12+ / iOS).
abstract class BlePermissionGateway {
  const BlePermissionGateway();

  /// Returns true when scan/connect permissions are granted (or not required).
  Future<bool> requestRuntimePermissions();
}
