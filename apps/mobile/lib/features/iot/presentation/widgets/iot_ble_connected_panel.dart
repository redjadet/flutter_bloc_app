import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/features/iot/presentation/cubit/iot_ble_cubit.dart';
import 'package:flutter_bloc_app/features/iot/presentation/cubit/iot_ble_state.dart';

class IotBleConnectedPanel extends StatelessWidget {
  const IotBleConnectedPanel({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final IotBleState state = context.watchState<IotBleCubit, IotBleState>();
    final IotBleCubit cubit = context.cubit<IotBleCubit>();
    final String? deviceId = state.selectedDeviceId;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              l10n.iotBleConnectedTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(deviceId ?? l10n.iotBleNoDeviceSelected),
            if (state.connection != null) Text(state.connection!.phase.name),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                FilledButton(
                  onPressed: deviceId == null || state.isConnected
                      ? null
                      : cubit.connectSelected,
                  child: Text(l10n.iotBleConnect),
                ),
                PlatformAdaptive.outlinedButton(
                  context: context,
                  onPressed: state.isConnected ? cubit.disconnect : null,
                  child: Text(l10n.iotBleDisconnect),
                ),
                PlatformAdaptive.outlinedButton(
                  context: context,
                  onPressed: state.isConnected ? cubit.reconnect : null,
                  child: Text(l10n.iotBleReconnect),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
