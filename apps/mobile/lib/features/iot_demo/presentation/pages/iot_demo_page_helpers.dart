import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/cubit/iot_demo_cubit.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/widgets/iot_demo_add_device_dialog.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';

/// Shows the add-device dialog and, on success, adds the device and selects it.
Future<void> showIotDemoAddDeviceDialog(final BuildContext context) async {
  final l10n = context.l10n;
  final result = await showAdaptiveDialog<IotDemoAddDeviceResult>(
    context: context,
    builder: (final ctx) => IotDemoAddDeviceDialogBody(l10n: l10n),
  );
  if (result != null && context.mounted) {
    final int suffix = Random().nextInt(0xFFFFFF);
    final deviceId =
        '${result.type.name}-${DateTime.now().microsecondsSinceEpoch}-'
        '${suffix.toRadixString(16)}';
    final device = IotDevice(
      id: deviceId,
      name: result.name,
      type: result.type,
      value: result.initialValue,
    );
    await context.cubit<IotDemoCubit>().addDevice(device);
    if (context.mounted) {
      context.cubit<IotDemoCubit>().selectDevice(deviceId);
    }
  }
}

/// Returns the localized label for [state].
String iotDemoConnectionStateLabel(
  final IotConnectionState state,
  final AppLocalizations l10n,
) => switch (state) {
  IotConnectionState.disconnected => l10n.iotDemoStatusDisconnected,
  IotConnectionState.connecting => l10n.iotDemoStatusConnecting,
  IotConnectionState.connected => l10n.iotDemoStatusConnected,
};
