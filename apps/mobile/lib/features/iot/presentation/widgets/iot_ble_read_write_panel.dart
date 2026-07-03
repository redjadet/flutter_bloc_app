import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/iot/presentation/cubit/iot_ble_cubit.dart';
import 'package:flutter_bloc_app/features/iot/presentation/cubit/iot_ble_state.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

class IotBleReadWritePanel extends StatefulWidget {
  const IotBleReadWritePanel({super.key});

  @override
  State<IotBleReadWritePanel> createState() => _IotBleReadWritePanelState();
}

class _IotBleReadWritePanelState extends State<IotBleReadWritePanel> {
  final TextEditingController _controller = TextEditingController();
  bool _hexMode = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final IotBleState state = context.watchState<IotBleCubit, IotBleState>();
    final IotBleCubit cubit = context.cubit<IotBleCubit>();
    final List<int>? last = state.lastReadValue;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              l10n.iotBleReadWriteTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.iotBleHexMode),
              value: _hexMode,
              onChanged: (final value) => setState(() => _hexMode = value),
            ),
            if (last != null)
              Text('${l10n.iotBleLastValue}: ${_formatBytes(last)}'),
            TextField(
              controller: _controller,
              decoration: InputDecoration(hintText: l10n.iotBleWriteHint),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                FilledButton(
                  onPressed: state.selectedCharacteristic == null
                      ? null
                      : cubit.readSelectedCharacteristic,
                  child: Text(l10n.iotBleRead),
                ),
                FilledButton(
                  onPressed: state.selectedCharacteristic == null
                      ? null
                      : () => cubit.writeSelectedCharacteristic(
                          _parseInput(_controller.text),
                        ),
                  child: Text(l10n.iotBleWrite),
                ),
                PlatformAdaptive.outlinedButton(
                  context: context,
                  onPressed: state.selectedCharacteristic == null
                      ? null
                      : () => cubit.writeSelectedCharacteristic(
                          _parseInput(_controller.text),
                          withoutResponse: true,
                        ),
                  child: Text(l10n.iotBleWriteNoResponse),
                ),
                PlatformAdaptive.outlinedButton(
                  context: context,
                  onPressed: state.selectedCharacteristic == null
                      ? null
                      : cubit.subscribeSelectedCharacteristic,
                  child: Text(l10n.iotBleSubscribe),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<int> _parseInput(final String raw) {
    final String text = raw.trim();
    if (text.isEmpty) {
      return <int>[];
    }
    if (_hexMode) {
      final String cleaned = text.replaceAll(RegExp('[^0-9a-fA-F]'), '');
      final List<int> bytes = <int>[];
      for (var i = 0; i < cleaned.length; i += 2) {
        final String pair = cleaned.substring(i, i + 2);
        bytes.add(int.parse(pair, radix: 16));
      }
      return bytes;
    }
    return text.codeUnits;
  }

  String _formatBytes(final List<int> bytes) =>
      bytes.map((final b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
}
