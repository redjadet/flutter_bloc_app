/// Runtime flags for the IoT BLE showcase (dart-define friendly).
class IotBleRuntimeConfig {
  const IotBleRuntimeConfig({required this.defaultMockMode});

  /// `true` when `IOT_BLE_MOCK_DEFAULT` is unset or explicitly true.
  factory IotBleRuntimeConfig.fromEnvironment() {
    const String raw = String.fromEnvironment(
      'IOT_BLE_MOCK_DEFAULT',
      defaultValue: 'true',
    );
    return IotBleRuntimeConfig(defaultMockMode: raw.toLowerCase() != 'false');
  }

  final bool defaultMockMode;
}
