import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_permission_gateway.dart';
import 'package:permission_handler/permission_handler.dart';

/// Requests platform BLE runtime permissions when FRB reports unauthorized.
class BlePermissionGatewayImpl implements BlePermissionGateway {
  const BlePermissionGatewayImpl({this.androidSdkIntProvider});

  final Future<int> Function()? androidSdkIntProvider;

  @override
  Future<bool> requestRuntimePermissions() async {
    if (kIsWeb) {
      return false;
    }
    if (Platform.isIOS) {
      return _requestIos();
    }
    if (Platform.isAndroid) {
      return _requestAndroid();
    }
    return false;
  }

  Future<bool> _requestIos() async {
    PermissionStatus status = await Permission.bluetooth.status;
    if (status.isGranted) {
      return true;
    }
    status = await Permission.bluetooth.request();
    return status.isGranted;
  }

  Future<bool> _requestAndroid() async {
    final List<Permission> permissions = <Permission>[
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ];
    if (await _androidSdkInt() <= 30) {
      permissions.add(Permission.location);
    }
    final Map<Permission, PermissionStatus> statuses = await permissions
        .request();
    return statuses.values.every(
      (final status) => status.isGranted || status.isLimited,
    );
  }

  Future<int> _androidSdkInt() async {
    final provider = androidSdkIntProvider;
    if (provider != null) {
      return provider();
    }
    final AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
    return info.version.sdkInt;
  }
}
