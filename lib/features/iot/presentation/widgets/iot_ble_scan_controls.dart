import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/iot/presentation/cubit/iot_ble_cubit.dart';
import 'package:flutter_bloc_app/features/iot/presentation/cubit/iot_ble_state.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

class IotBleScanControls extends StatelessWidget {
  const IotBleScanControls({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final IotBleState state = context.watchState<IotBleCubit, IotBleState>();
    final IotBleCubit cubit = context.cubit<IotBleCubit>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              l10n.iotBleScanTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButton<Duration>(
              value: state.scanTimeout,
              items: <DropdownMenuItem<Duration>>[
                DropdownMenuItem<Duration>(
                  value: const Duration(seconds: 10),
                  child: Text(l10n.iotBleScanTimeout10),
                ),
                DropdownMenuItem<Duration>(
                  value: const Duration(seconds: 30),
                  child: Text(l10n.iotBleScanTimeout30),
                ),
                DropdownMenuItem<Duration>(
                  value: const Duration(seconds: 60),
                  child: Text(l10n.iotBleScanTimeout60),
                ),
              ],
              onChanged: state.isScanning
                  ? null
                  : (final value) {
                      if (value != null) {
                        cubit.setScanTimeout(value);
                      }
                    },
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton(
                    onPressed: state.isScanning ? null : cubit.startScan,
                    child: Text(l10n.iotBleStartScan),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PlatformAdaptive.outlinedButton(
                    context: context,
                    onPressed: state.isScanning ? cubit.stopScan : null,
                    child: Text(l10n.iotBleStopScan),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
