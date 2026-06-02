part of 'iot_demo_page_body.dart';

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
