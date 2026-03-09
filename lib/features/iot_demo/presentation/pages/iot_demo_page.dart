import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_value_range.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device_command.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device_type_extension.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/cubit/iot_demo_cubit.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/cubit/iot_demo_state.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/widgets/iot_demo_set_value_dialog.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
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

/// IoT demo page: list devices, connect, disconnect, send commands.
class IotDemoPage extends StatelessWidget {
  const IotDemoPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.iotDemoPageTitle,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: TypeSafeBlocBuilder<IotDemoCubit, IotDemoState>(
              builder: (final context, final state) {
                return state.when(
                  initial: () => const _LoadingBody(),
                  loading: () => const _LoadingBody(),
                  loaded: (final devices, final selectedDeviceId) =>
                      _LoadedBody(
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
          ),
        ],
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
    final IotDevice? selected = selectedDeviceId != null
        ? devices.firstWhereOrNull((final d) => d.id == selectedDeviceId)
        : null;
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

  void _onSliderChanged(final BuildContext context, final double value) {
    final double clamped = iotDemoClampAndRound(
      value,
      iotDemoValueMin,
      iotDemoValueMax,
    );
    if (clamped == device.value) return;
    // Slider callback is synchronous; cubit handles async errors internally.
    // ignore: discarded_futures
    context.cubit<IotDemoCubit>().sendCommand(
      device.id,
      IotDeviceCommand.setValue(clamped),
    );
  }

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
          Row(
            children: <Widget>[
              Text(
                device.toggledOn ? l10n.iotDemoStateOn : l10n.iotDemoStateOff,
                style: bodyVariantStyle,
              ),
              SizedBox(width: context.responsiveHorizontalGapS),
              Switch.adaptive(
                value: device.toggledOn,
                onChanged: (_) => context.cubit<IotDemoCubit>().sendCommand(
                  device.id,
                  const IotDeviceCommand.toggle(),
                ),
              ),
            ],
          ),
          if (device.type.hasValue) ...[
            SizedBox(height: context.responsiveGapXS),
            Text(
              l10n.iotDemoCurrentValue(device.value.toString()),
              style: bodyVariantStyle,
            ),
            SizedBox(height: context.responsiveGapXS),
            Slider.adaptive(
              value: device.value.clamp(iotDemoValueMin, iotDemoValueMax),
              max: iotDemoValueMax,
              onChanged: (final v) => _onSliderChanged(context, v),
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
                onPressed:
                    device.connectionState == IotConnectionState.connecting
                    ? null
                    : () => context.cubit<IotDemoCubit>().connect(device.id),
                child: Text(l10n.iotDemoConnect),
              ),
            if (connected)
              OutlinedButton(
                onPressed: () =>
                    context.cubit<IotDemoCubit>().disconnect(device.id),
                child: Text(l10n.iotDemoDisconnect),
              ),
            if (connected && device.type.hasValue)
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
      builder: (final ctx) => IotDemoSetValueDialogBody(
        initialValue: device.value.clamp(iotDemoValueMin, iotDemoValueMax),
        l10n: l10n,
        minValue: iotDemoValueMin,
        maxValue: iotDemoValueMax,
      ),
    );
    if (value != null && context.mounted) {
      final double clamped = iotDemoClampAndRound(
        value,
        iotDemoValueMin,
        iotDemoValueMax,
      );
      await context.cubit<IotDemoCubit>().sendCommand(
        device.id,
        IotDeviceCommand.setValue(clamped),
      );
    }
  }
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
