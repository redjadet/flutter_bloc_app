import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/iot/domain/entities/ble_service.dart';
import 'package:flutter_bloc_app/features/iot/presentation/cubit/iot_ble_cubit.dart';
import 'package:flutter_bloc_app/features/iot/presentation/cubit/iot_ble_state.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';

class IotBleServicesExplorer extends StatelessWidget {
  const IotBleServicesExplorer({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final IotBleState state = context.watchState<IotBleCubit, IotBleState>();
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.iotBleServicesTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (state.services.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(l10n.iotBleNoServices),
            )
          else
            for (final BleService service in state.services)
              ListTile(
                title: Text(service.uuid),
                subtitle: Text(
                  l10n.iotBleCharacteristicCount(
                    service.characteristics.length,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
