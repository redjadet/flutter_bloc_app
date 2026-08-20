import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/utils/bloc_provider_helpers.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/iot/presentation/cubit/iot_ble_cubit.dart';
import 'package:flutter_bloc_app/features/iot/presentation/widgets/iot_ble_section.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/pages/iot_demo_page_helpers.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/widgets/iot_demo_cloud_tab.dart';
import 'package:material_ui/material_ui.dart';

enum IotDemoHubTab { cloud, ble }

/// App-layer composition: Cloud IoT + local BLE tabs on `/iot-demo`.
class const IotDemoHubPage({
  required final bool showBackendDisabledBanner,
  required final IotBleCubit Function() createIotBleCubit,
  super.key,
}) extends StatefulWidget {
  @override
  State<IotDemoHubPage> createState() => _IotDemoHubPageState();
}

class _IotDemoHubPageState extends State<IotDemoHubPage> {
  IotDemoHubTab _tab = IotDemoHubTab.cloud;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.iotDemoPageTitle,
      floatingActionButton: _tab == IotDemoHubTab.cloud
          ? Semantics(
              button: true,
              label: l10n.iotDemoAddDeviceTooltip,
              child: FloatingActionButton(
                onPressed: () => showIotDemoAddDeviceDialog(context),
                tooltip: l10n.iotDemoAddDeviceTooltip,
                child: const Icon(Icons.add),
              ),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SegmentedButton<IotDemoHubTab>(
              segments: <ButtonSegment<IotDemoHubTab>>[
                ButtonSegment<IotDemoHubTab>(
                  value: IotDemoHubTab.cloud,
                  label: Text(l10n.iotDemoHubTabCloud),
                ),
                ButtonSegment<IotDemoHubTab>(
                  value: IotDemoHubTab.ble,
                  label: Text(l10n.iotDemoHubTabBle),
                ),
              ],
              selected: <IotDemoHubTab>{_tab},
              onSelectionChanged: (selected) {
                final IotDemoHubTab? next = selected.firstOrNull;
                if (next != null && next != _tab) {
                  setState(() => _tab = next);
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: switch (_tab) {
              IotDemoHubTab.cloud => IotDemoCloudTab(
                showBackendDisabledBanner: widget.showBackendDisabledBanner,
              ),
              IotDemoHubTab.ble =>
                BlocProviderHelpers.withAsyncInit<IotBleCubit>(
                  create: widget.createIotBleCubit,
                  init: (cubit) => cubit.initialize(),
                  child: const IotBleSection(),
                ),
            },
          ),
        ],
      ),
    );
  }
}
