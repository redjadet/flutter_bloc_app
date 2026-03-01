import 'package:flutter/services.dart';

const String _channelName = 'com.example.flutter_bloc_app/native';
const String _methodGetPlatformInfo = 'getPlatformInfo';
const String _methodHasGoogleMapsApiKey = 'hasGoogleMapsApiKey';
const String _keyBatteryLevel = 'batteryLevel';

class NativePlatformService {
  NativePlatformService({final MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(_channelName);

  final MethodChannel _channel;

  Future<NativePlatformInfo> getPlatformInfo() async {
    final Map<String, dynamic>? result = await _channel
        .invokeMapMethod<String, dynamic>(_methodGetPlatformInfo);
    return NativePlatformInfo.fromMap(result);
  }

  Future<bool> hasGoogleMapsApiKey() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>(
        _methodHasGoogleMapsApiKey,
      );
      return result ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}

class NativePlatformInfo {
  const NativePlatformInfo({
    required this.platform,
    required this.version,
    this.manufacturer,
    this.model,
    this.batteryLevel,
  });

  factory NativePlatformInfo.fromMap(final Map<String, dynamic>? map) {
    if (map == null) {
      return const NativePlatformInfo(platform: 'unknown', version: 'unknown');
    }
    return NativePlatformInfo(
      platform: _stringFromMap(map, 'platform') ?? 'unknown',
      version: _stringFromMap(map, 'version') ?? 'unknown',
      manufacturer: _stringFromMap(map, 'manufacturer'),
      model: _stringFromMap(map, 'model'),
      batteryLevel: _batteryLevelFromMap(map),
    );
  }

  static String? _stringFromMap(
    final Map<String, dynamic> map,
    final String key,
  ) {
    final value = map[key];
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return null;
  }

  static int? _batteryLevelFromMap(final Map<String, dynamic> map) {
    final value = map[_keyBatteryLevel];
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      final parsed = num.tryParse(value.trim());
      return parsed?.toInt();
    }
    return null;
  }

  final String platform;
  final String version;
  final String? manufacturer;
  final String? model;
  final int? batteryLevel;

  @override
  String toString() {
    final StringBuffer buffer = StringBuffer('$platform $version');
    if (manufacturer != null || model != null) {
      buffer.write(' [');
      if (manufacturer != null) {
        buffer.write(manufacturer);
      }
      if (manufacturer != null && model != null) {
        buffer.write(' ');
      }
      if (model != null) {
        buffer.write(model);
      }
      buffer.write(']');
    }
    if (batteryLevel != null) {
      buffer.write(' (battery: $batteryLevel%)');
    }
    return buffer.toString();
  }
}
