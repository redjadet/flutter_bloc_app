import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/iot/domain/entities/ble_discovered_device.dart';
import 'package:flutter_bloc_app/features/iot/presentation/cubit/iot_ble_cubit.dart';
import 'package:flutter_bloc_app/features/iot/presentation/cubit/iot_ble_state.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';

class IotBleDeviceList extends StatelessWidget {
  const IotBleDeviceList({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final IotBleState state = context.watchState<IotBleCubit, IotBleState>();
    final IotBleCubit cubit = context.cubit<IotBleCubit>();
    if (state.devices.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.iotBleNoDevices),
        ),
      );
    }
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.iotBleDeviceListTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final BleDiscoveredDevice device in state.devices)
            ListTile(
              selected: state.selectedDeviceId == device.id,
              title: Text(device.name),
              subtitle: Text('${device.id} · ${device.rssi} dBm'),
              trailing: device.connectable
                  ? const Icon(Icons.bluetooth_connected)
                  : const Icon(Icons.bluetooth_disabled),
              onTap: () => cubit.selectDevice(device.id),
            ),
        ],
      ),
    );
  }
}
