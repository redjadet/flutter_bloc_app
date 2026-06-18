import 'package:flutter_bloc_app/features/iot/domain/iot_ble_error_code.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

String resolveIotBleErrorMessage(
  final AppLocalizations l10n,
  final IotBleErrorCode code, [
  final String? detail,
]) {
  final String base = switch (code) {
    IotBleErrorCode.initialize => l10n.iotBleErrorInitialize,
    IotBleErrorCode.permissionDenied => l10n.iotBleErrorPermissionDenied,
    IotBleErrorCode.bluetoothDisabled => l10n.iotBleErrorBluetoothDisabled,
    IotBleErrorCode.scan => l10n.iotBleErrorScan,
    IotBleErrorCode.connect => l10n.iotBleErrorConnect,
    IotBleErrorCode.disconnect => l10n.iotBleErrorDisconnect,
    IotBleErrorCode.discover => l10n.iotBleErrorDiscover,
    IotBleErrorCode.read => l10n.iotBleErrorRead,
    IotBleErrorCode.write => l10n.iotBleErrorWrite,
    IotBleErrorCode.subscribe => l10n.iotBleErrorSubscribe,
    IotBleErrorCode.unsupportedPlatform => l10n.iotBleErrorUnsupportedPlatform,
    IotBleErrorCode.characteristicNotFound =>
      l10n.iotBleErrorCharacteristicNotFound,
  };
  if (detail == null || detail.isEmpty) {
    return base;
  }
  return '$base ($detail)';
}
