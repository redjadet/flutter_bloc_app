/// Runtime BLE permission escalation (Android 12+ / iOS).
abstract class BlePermissionGateway {
  const new();

  /// Returns true when scan/connect permissions are granted (or not required).
  Future<bool> requestRuntimePermissions();
}
