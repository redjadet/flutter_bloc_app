import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/config/backend_availability.dart';
import 'package:flutter_bloc_app/app/config/iot_ble_runtime_config.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/utils/bloc_provider_helpers.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/iot/data/mock_ble_repository.dart';
import 'package:flutter_bloc_app/features/iot/data/mock_classic_bluetooth_repository.dart';
import 'package:flutter_bloc_app/features/iot/data/reactive_ble_repository.dart';
import 'package:flutter_bloc_app/features/iot/data/unsupported_ble_repository.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_platform_gateway.dart';
import 'package:flutter_bloc_app/features/iot/presentation/cubit/iot_ble_cubit.dart';
import 'package:flutter_bloc_app/features/iot/presentation/widgets/iot_ble_section.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/pages/iot_demo_page_helpers.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/widgets/iot_demo_cloud_tab.dart';

enum IotDemoHubTab { cloud, ble }

/// App-layer composition: Cloud IoT + local BLE tabs on `/iot-demo`.
class IotDemoHubPage extends StatefulWidget {
  const IotDemoHubPage({required this.backendAvailability, super.key});

  final BackendAvailability backendAvailability;

  @override
  State<IotDemoHubPage> createState() => _IotDemoHubPageState();
}

class _IotDemoHubPageState extends State<IotDemoHubPage> {
  IotDemoHubTab _tab = IotDemoHubTab.cloud;

  @override
  Widget build(final BuildContext context) {
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
              onSelectionChanged: (final selected) {
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
                backendAvailability: widget.backendAvailability,
              ),
              IotDemoHubTab.ble =>
                BlocProviderHelpers.withAsyncInit<IotBleCubit>(
                  create: () => IotBleCubit(
                    mockRepository: getIt<MockBleRepository>(),
                    reactiveRepository:
                        getIt.isRegistered<ReactiveBleRepository>()
                        ? getIt<ReactiveBleRepository>()
                        : getIt<UnsupportedBleRepository>(),
                    classicRepository: getIt<MockClassicBluetoothRepository>(),
                    platformGateway: getIt<BlePlatformGateway>(),
                    runtimeConfig: getIt<IotBleRuntimeConfig>(),
                    timerService: getIt<TimerService>(),
                  ),
                  init: (final cubit) => cubit.initialize(),
                  child: const IotBleSection(),
                ),
            },
          ),
        ],
      ),
    );
  }
}
