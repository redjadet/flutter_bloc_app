import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device_command.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/cubit/iot_demo_cubit.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/cubit/iot_demo_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/navigation.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_card.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/shared/widgets/type_safe_bloc_selector.dart';

String _connectionStateLabel(
  final IotConnectionState state,
  final AppLocalizations l10n,
) => switch (state) {
  IotConnectionState.disconnected => l10n.iotDemoStatusDisconnected,
  IotConnectionState.connecting => l10n.iotDemoStatusConnecting,
  IotConnectionState.connected => l10n.iotDemoStatusConnected,
};

String _deviceTypeLabel(
  final IotDeviceType type,
  final AppLocalizations l10n,
) => switch (type) {
  IotDeviceType.light => l10n.iotDemoDeviceTypeLight,
  IotDeviceType.thermostat => l10n.iotDemoDeviceTypeThermostat,
  IotDeviceType.plug => l10n.iotDemoDeviceTypePlug,
  IotDeviceType.sensor => l10n.iotDemoDeviceTypeSensor,
  IotDeviceType.switch_ => l10n.iotDemoDeviceTypeSwitch,
};

bool _deviceHasValue(final IotDeviceType type) =>
    type == IotDeviceType.thermostat || type == IotDeviceType.sensor;

/// IoT demo page: list devices, connect, disconnect, send commands.
class IotDemoPage extends StatelessWidget {
  const IotDemoPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.iotDemoPageTitle,
      body: TypeSafeBlocBuilder<IotDemoCubit, IotDemoState>(
        builder: (final context, final state) {
          return state.when(
            initial: () => const _LoadingBody(),
            loading: () => const _LoadingBody(),
            loaded: (final devices, final selectedDeviceId) => _LoadedBody(
              devices: devices,
              selectedDeviceId: selectedDeviceId,
            ),
            error: (final message) => CommonErrorView(
              message: message,
              onRetry: () => context.cubit<IotDemoCubit>().initialize(),
            ),
          );
        },
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(final BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({
    required this.devices,
    this.selectedDeviceId,
  });

  final List<IotDevice> devices;
  final String? selectedDeviceId;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    if (devices.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(context.responsiveGapL),
          child: Text(
            l10n.iotDemoDeviceListEmpty,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    IotDevice? selected;
    if (selectedDeviceId != null) {
      for (final d in devices) {
        if (d.id == selectedDeviceId) {
          selected = d;
          break;
        }
      }
    }
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: context.responsiveGapM),
          ...devices.map(
            (final d) => Padding(
              padding: EdgeInsets.only(bottom: context.responsiveGapS),
              child: _DeviceTile(
                device: d,
                isSelected: d.id == selectedDeviceId,
                connectionLabel: _connectionStateLabel(
                  d.connectionState,
                  l10n,
                ),
                typeLabel: _deviceTypeLabel(d.type, l10n),
                onTap: () => context.cubit<IotDemoCubit>().selectDevice(
                  selectedDeviceId == d.id ? null : d.id,
                ),
              ),
            ),
          ),
          if (selected != null) ...[
            SizedBox(height: context.responsiveGapL),
            CommonCard(
              child: _SelectedDeviceActions(
                device: selected,
              ),
            ),
          ],
          SizedBox(height: context.responsiveGapL),
        ],
      ),
    );
  }
}

class _SelectedDeviceActions extends StatelessWidget {
  const _SelectedDeviceActions({required this.device});

  final IotDevice device;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final bodyVariantStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final connected = device.connectionState == IotConnectionState.connected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          device.name,
          style: theme.textTheme.titleMedium,
        ),
        SizedBox(height: context.responsiveGapS),
        Text(
          _connectionStateLabel(device.connectionState, l10n),
          style: bodyVariantStyle,
        ),
        if (connected) ...[
          SizedBox(height: context.responsiveGapXS),
          Text(
            device.toggledOn ? l10n.iotDemoStateOn : l10n.iotDemoStateOff,
            style: bodyVariantStyle,
          ),
          if (_deviceHasValue(device.type)) ...[
            SizedBox(height: context.responsiveGapXS),
            Text(
              l10n.iotDemoCurrentValue(device.value.toString()),
              style: bodyVariantStyle,
            ),
          ],
        ],
        SizedBox(height: context.responsiveGapM),
        Wrap(
          spacing: context.responsiveHorizontalGapS,
          runSpacing: context.responsiveGapS,
          children: <Widget>[
            if (device.connectionState != IotConnectionState.connected)
              FilledButton(
                onPressed: device.connectionState == IotConnectionState.connecting
                    ? null
                    : () => context.cubit<IotDemoCubit>().connect(device.id),
                child: Text(l10n.iotDemoConnect),
              ),
            if (connected)
              OutlinedButton(
                onPressed: () => context.cubit<IotDemoCubit>().disconnect(device.id),
                child: Text(l10n.iotDemoDisconnect),
              ),
            if (connected)
              OutlinedButton(
                onPressed: () => context.cubit<IotDemoCubit>().sendCommand(
                  device.id,
                  const IotDeviceCommand.toggle(),
                ),
                child: Text(l10n.iotDemoToggle),
              ),
            if (connected && _deviceHasValue(device.type))
              OutlinedButton(
                onPressed: () async {
                  await _SelectedDeviceActions.showSetValueDialog(
                    context,
                    device,
                    l10n,
                  );
                },
                child: Text(l10n.iotDemoSetValue),
              ),
          ],
        ),
      ],
    );
  }

  static Future<void> showSetValueDialog(
    final BuildContext context,
    final IotDevice device,
    final AppLocalizations l10n,
  ) async {
    final double? value = await showAdaptiveDialog<double>(
      context: context,
      builder: (final ctx) => _SetValueDialogBody(
        initialValue: device.value,
        l10n: l10n,
      ),
    );
    if (value != null && context.mounted) {
      unawaited(
        context.cubit<IotDemoCubit>().sendCommand(
          device.id,
          IotDeviceCommand.setValue(value),
        ),
      );
    }
  }
}

/// Stateful dialog content so [TextEditingController] is disposed in [State.dispose]
/// after the route is torn down, avoiding "used after being disposed".
class _SetValueDialogBody extends StatefulWidget {
  const _SetValueDialogBody({
    required this.initialValue,
    required this.l10n,
  });

  final double initialValue;
  final AppLocalizations l10n;

  @override
  State<_SetValueDialogBody> createState() => _SetValueDialogBodyState();
}

class _SetValueDialogBodyState extends State<_SetValueDialogBody> {
  late final TextEditingController _controller;

  static const TextInputType _decimalKeyboard = TextInputType.numberWithOptions(decimal: true);

  @override
  void initState() {
    super.initState();
    final double v = widget.initialValue;
    _controller = TextEditingController(
      text: v == v.roundToDouble() ? v.toInt().toString() : v.toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double? get _parsedValue => double.tryParse(_controller.text);

  void _submitValue(final BuildContext context) {
    final p = _parsedValue;
    if (p != null) {
      NavigationUtils.maybePop(context, result: p);
    }
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = widget.l10n;
    final cancelLabel = l10n.cancelButtonLabel;
    final okLabel = MaterialLocalizations.of(context).okButtonLabel;
    final useCupertino = PlatformAdaptive.isCupertinoFromTheme(Theme.of(context));
    return useCupertino
        ? _buildCupertinoDialog(context, l10n, cancelLabel, okLabel)
        : _buildMaterialDialog(context, l10n, cancelLabel, okLabel);
  }

  Widget _buildMaterialDialog(
    final BuildContext context,
    final AppLocalizations l10n,
    final String cancelLabel,
    final String okLabel,
  ) => AlertDialog(
    title: Text(l10n.iotDemoSetValue),
    content: TextField(
      controller: _controller,
      keyboardType: _decimalKeyboard,
      decoration: InputDecoration(labelText: l10n.iotDemoSetValueHint),
      onSubmitted: (_) => _submitValue(context),
    ),
    actions: <Widget>[
      PlatformAdaptive.dialogAction(
        context: context,
        onPressed: () => NavigationUtils.maybePop(context),
        label: cancelLabel,
      ),
      PlatformAdaptive.dialogAction(
        context: context,
        onPressed: () => _submitValue(context),
        label: okLabel,
      ),
    ],
  );

  Widget _buildCupertinoDialog(
    final BuildContext context,
    final AppLocalizations l10n,
    final String cancelLabel,
    final String okLabel,
  ) => CupertinoAlertDialog(
    title: Text(l10n.iotDemoSetValue),
    content: Builder(
      builder: (final ctx) => Padding(
        padding: EdgeInsets.only(top: context.responsiveGapM),
        child: CupertinoTextField(
          controller: _controller,
          keyboardType: _decimalKeyboard,
          placeholder: l10n.iotDemoSetValueHint,
          onSubmitted: (_) => _submitValue(context),
        ),
      ),
    ),
    actions: <CupertinoDialogAction>[
      CupertinoDialogAction(
        onPressed: () => NavigationUtils.maybePop(context),
        child: Text(cancelLabel),
      ),
      CupertinoDialogAction(
        onPressed: () => _submitValue(context),
        child: Text(okLabel),
      ),
    ],
  );
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({
    required this.device,
    required this.isSelected,
    required this.connectionLabel,
    required this.typeLabel,
    required this.onTap,
  });

  final IotDevice device;
  final bool isSelected;
  final String connectionLabel;
  final String typeLabel;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: '${device.name}, $typeLabel, $connectionLabel',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.responsiveBorderRadius),
        child: CommonCard(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveHorizontalGapM,
            vertical: context.responsiveGapM,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      device.name,
                      style: theme.textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: context.responsiveGapXS),
                    Text(
                      '$typeLabel · $connectionLabel',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
