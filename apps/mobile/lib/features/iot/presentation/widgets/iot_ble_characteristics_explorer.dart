import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_service.dart';
import 'package:flutter_bloc_app/features/iot/presentation/cubit/iot_ble_cubit.dart';
import 'package:flutter_bloc_app/features/iot/presentation/cubit/iot_ble_state.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';

class IotBleCharacteristicsExplorer extends StatelessWidget {
  const IotBleCharacteristicsExplorer({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final IotBleState state = context.watchState<IotBleCubit, IotBleState>();
    final String? deviceId = state.selectedDeviceId;
    final IotBleCubit cubit = context.cubit<IotBleCubit>();
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.iotBleCharacteristicsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (deviceId == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(l10n.iotBleNoDeviceSelected),
            )
          else
            for (final BleService service in state.services)
              for (final BleCharacteristic characteristic
                  in service.characteristics)
                ListTile(
                  selected:
                      state.selectedCharacteristic?.characteristicUuid ==
                      characteristic.uuid,
                  title: Text(characteristic.uuid),
                  subtitle: Text(_props(characteristic)),
                  onTap: () => cubit.selectCharacteristic(
                    BleCharacteristicRef(
                      deviceId: deviceId,
                      serviceUuid: service.uuid,
                      characteristicUuid: characteristic.uuid,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  String _props(final BleCharacteristic characteristic) {
    final List<String> props = <String>[];
    if (characteristic.canRead) props.add('R');
    if (characteristic.canWrite) props.add('W');
    if (characteristic.canWriteWithoutResponse) props.add('Wn');
    if (characteristic.canNotify) props.add('N');
    if (characteristic.canIndicate) props.add('I');
    return props.join(' ');
  }
}
