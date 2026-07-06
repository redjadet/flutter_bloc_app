import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_log_entry.dart';
import 'package:flutter_bloc_app/features/iot/presentation/cubit/iot_ble_cubit.dart';
import 'package:flutter_bloc_app/features/iot/presentation/cubit/iot_ble_state.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

class IotBleEventLogPanel extends StatelessWidget {
  const IotBleEventLogPanel({super.key});

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
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    l10n.iotBleEventLogTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                PlatformAdaptive.textButton(
                  context: context,
                  onPressed: state.logs.isEmpty
                      ? null
                      : context.cubit<IotBleCubit>().clearLogs,
                  child: Text(l10n.iotBleClearLog),
                ),
              ],
            ),
          ),
          if (state.logs.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(l10n.iotBleLogEmpty),
            )
          else
            SizedBox(
              height: 160,
              child: ListView.builder(
                itemCount: state.logs.length,
                itemBuilder: (final context, final index) {
                  final BleLogEntry entry =
                      state.logs[state.logs.length - 1 - index];
                  return ListTile(
                    key: ValueKey<String>(
                      '${entry.timestamp.millisecondsSinceEpoch}-${entry.kind.name}',
                    ),
                    dense: true,
                    title: Text(entry.message),
                    subtitle: Text('${entry.kind.name} · ${entry.timestamp}'),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
