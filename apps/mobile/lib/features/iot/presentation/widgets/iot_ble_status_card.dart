import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_adapter_status.dart';
import 'package:flutter_bloc_app/features/iot/presentation/cubit/iot_ble_cubit.dart';
import 'package:flutter_bloc_app/features/iot/presentation/cubit/iot_ble_state.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';

class IotBleStatusCard extends StatelessWidget {
  const IotBleStatusCard({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final IotBleState state = context.watchState<IotBleCubit, IotBleState>();
    final BleAdapterStatus? adapter = state.adapterStatus;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.iotBleStatusTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(adapter?.state.name ?? l10n.iotBleAdapterUnknown),
            if (!state.canToggleRealBle)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(l10n.iotBlePlatformMockOnly),
              ),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: <ButtonSegment<bool>>[
                ButtonSegment<bool>(
                  value: true,
                  label: Text(l10n.iotBleMockModeLabel),
                ),
                ButtonSegment<bool>(
                  value: false,
                  label: Text(l10n.iotBleRealModeLabel),
                ),
              ],
              selected: <bool>{state.useMockBle},
              onSelectionChanged: state.canToggleRealBle || state.useMockBle
                  ? (final selected) => _toggleMode(context, selected)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleMode(final BuildContext context, final Set<bool> selected) {
    final bool? useMock = selected.firstOrNull;
    if (useMock != null) {
      unawaited(
        context.cubit<IotBleCubit>().toggleBleMode(useMock: useMock),
      );
    }
  }
}
