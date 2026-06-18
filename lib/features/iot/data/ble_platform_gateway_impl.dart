import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_platform_gateway.dart';

/// Resolves real BLE support from the host platform.
class BlePlatformGatewayImpl implements BlePlatformGateway {
  const BlePlatformGatewayImpl();

  @override
  bool get supportsRealBle {
    if (kIsWeb) {
      return false;
    }
    return Platform.isAndroid || Platform.isIOS;
  }

  @override
  bool get supportsRealClassic => false;
}
