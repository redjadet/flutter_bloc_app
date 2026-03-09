import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

/// Returns the localized label for [type].
String iotDemoDeviceTypeLabel(
  final IotDeviceType type,
  final AppLocalizations l10n,
) => switch (type) {
  IotDeviceType.light => l10n.iotDemoDeviceTypeLight,
  IotDeviceType.thermostat => l10n.iotDemoDeviceTypeThermostat,
  IotDeviceType.plug => l10n.iotDemoDeviceTypePlug,
  IotDeviceType.sensor => l10n.iotDemoDeviceTypeSensor,
  IotDeviceType.switch_ => l10n.iotDemoDeviceTypeSwitch,
};
