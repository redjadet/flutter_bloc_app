import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_error_code.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

String resolveIotDemoErrorMessage(
  final AppLocalizations l10n,
  final IotDemoErrorCode code,
  final String? detail,
) {
  if (code == IotDemoErrorCode.add &&
      detail != null &&
      detail.isNotEmpty &&
      !detail.startsWith('Exception:')) {
    return detail;
  }
  return switch (code) {
    IotDemoErrorCode.load => l10n.iotDemoErrorLoad,
    IotDemoErrorCode.connect => l10n.iotDemoErrorConnect,
    IotDemoErrorCode.disconnect => l10n.iotDemoErrorDisconnect,
    IotDemoErrorCode.command => l10n.iotDemoErrorCommand,
    IotDemoErrorCode.add => l10n.iotDemoErrorAdd,
  };
}
