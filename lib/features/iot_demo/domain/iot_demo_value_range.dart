/// Shared value range for IoT demo devices that have a numeric value
/// (e.g. thermostat, sensor). Used for sliders and set-value validation.
const double iotDemoValueMin = 0;
const double iotDemoValueMax = 50;

/// Max length for device name (aligns with typical DB varchar limits).
const int iotDemoDeviceNameMaxLength = 255;

/// Clamps [value] to [min]–[max] and rounds to 2 decimal places.
double iotDemoClampAndRound(
  final double value,
  final double min,
  final double max,
) => (value.clamp(min, max) * 100).round() / 100;
