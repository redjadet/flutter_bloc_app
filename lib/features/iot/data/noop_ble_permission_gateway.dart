import 'package:flutter_bloc_app/features/iot/domain/ble_permission_gateway.dart';

/// Web/desktop — no runtime BLE permission prompts.
class NoOpBlePermissionGateway implements BlePermissionGateway {
  const NoOpBlePermissionGateway();

  @override
  Future<bool> requestRuntimePermissions() async => false;
}
