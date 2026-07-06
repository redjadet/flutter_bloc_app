import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/iot/domain/classic_bt_device.dart';
import 'package:flutter_bloc_app/features/iot/presentation/cubit/iot_ble_cubit.dart';
import 'package:flutter_bloc_app/features/iot/presentation/cubit/iot_ble_state.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

class IotBleClassicSection extends StatefulWidget {
  const IotBleClassicSection({super.key});

  @override
  State<IotBleClassicSection> createState() => _IotBleClassicSectionState();
}

class _IotBleClassicSectionState extends State<IotBleClassicSection> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

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
              l10n.iotBleClassicTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(l10n.iotBleClassicLimitation),
            const SizedBox(height: 12),
            for (final ClassicBtDevice device in state.classicDevices)
              ListTile(
                title: Text(device.name),
                trailing: device.isConnected
                    ? const Icon(Icons.link)
                    : PlatformAdaptive.textButton(
                        context: context,
                        onPressed: () => cubit.connectClassicDevice(device.id),
                        child: Text(l10n.iotBleConnect),
                      ),
              ),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: l10n.iotBleClassicMessageHint,
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: state.selectedClassicDeviceId == null
                  ? null
                  : () => cubit.sendClassicMessage(_messageController.text),
              child: Text(l10n.iotBleClassicSend),
            ),
            const SizedBox(height: 8),
            for (final ClassicBtMessage message in state.classicMessages)
              ListTile(
                dense: true,
                title: Text(message.text),
                subtitle: Text(message.direction.name),
              ),
          ],
        ),
      ),
    );
  }
}
