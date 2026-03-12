import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_value_range.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device_command.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device_type_extension.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/cubit/iot_demo_cubit.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/pages/iot_demo_page_helpers.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/utils/iot_demo_device_type_label.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/widgets/iot_demo_set_value_dialog.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/widgets/common_card.dart';

/// Loading state body for the IoT demo page.
class IotDemoLoadingBody extends StatelessWidget {
  const IotDemoLoadingBody({super.key});

  @override
  Widget build(final BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

/// Loaded state body: device list and selected device actions.
class IotDemoLoadedBody extends StatelessWidget {
  const IotDemoLoadedBody({
    required this.devices,
    this.selectedDeviceId,
    super.key,
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
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: context.responsiveGapM),
          for (final d in devices) ...[
            Padding(
              padding: EdgeInsets.only(bottom: context.responsiveGapS),
              child: IotDemoDeviceTile(
                device: d,
                isSelected: d.id == selectedDeviceId,
                connectionLabel: iotDemoConnectionStateLabel(
                  d.connectionState,
                  l10n,
                ),
                typeLabel: iotDemoDeviceTypeLabel(d.type, l10n),
                onTap: () => context.cubit<IotDemoCubit>().selectDevice(
                  selectedDeviceId == d.id ? null : d.id,
                ),
              ),
            ),
            if (d.id == selectedDeviceId) ...[
              Padding(
                padding: EdgeInsets.only(bottom: context.responsiveGapS),
                child: CommonCard(
                  child: IotDemoSelectedDeviceActions(device: d),
                ),
              ),
            ],
          ],
          SizedBox(height: context.responsiveGapL),
        ],
      ),
    );
  }
}

/// Actions panel for the currently selected device.
class IotDemoSelectedDeviceActions extends StatelessWidget {
  const IotDemoSelectedDeviceActions({
    required this.device,
    super.key,
  });

  final IotDevice device;

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

  void _onSliderChanged(final BuildContext context, final double value) {
    final double clamped = iotDemoClampAndRound(
      value,
      iotDemoValueMin,
      iotDemoValueMax,
    );
    if (clamped == device.value) return;
    // ignore: discarded_futures — slider callback is sync; cubit handles async
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
          iotDemoConnectionStateLabel(device.connectionState, l10n),
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
                  await IotDemoSelectedDeviceActions.showSetValueDialog(
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
}

/// A single device row in the IoT demo list.
class IotDemoDeviceTile extends StatelessWidget {
  const IotDemoDeviceTile({
    required this.device,
    required this.isSelected,
    required this.connectionLabel,
    required this.typeLabel,
    required this.onTap,
    super.key,
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
