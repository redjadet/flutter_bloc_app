import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_value_range.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device_command.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device_type_extension.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/cubit/iot_demo_cubit.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/pages/iot_demo_page_helpers.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/widgets/iot_demo_device_type_label.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/widgets/iot_demo_set_value_dialog.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

part 'iot_demo_page_body.part.dart';

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
