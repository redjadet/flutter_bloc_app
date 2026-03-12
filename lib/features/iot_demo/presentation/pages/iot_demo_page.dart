import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_device_filter.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/cubit/iot_demo_cubit.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/cubit/iot_demo_state.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/pages/iot_demo_page_body.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/pages/iot_demo_page_helpers.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/shared/widgets/type_safe_bloc_selector.dart';

/// IoT demo page: list devices, connect, disconnect, send commands.
class IotDemoPage extends StatefulWidget {
  const IotDemoPage({super.key});

  @override
  State<IotDemoPage> createState() => _IotDemoPageState();
}

class _IotDemoPageState extends State<IotDemoPage> {
  bool _didStartSync = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didStartSync) return;
    _didStartSync = true;
    context.cubit<SyncStatusCubit>().ensureStarted();
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.iotDemoPageTitle,
      floatingActionButton: Semantics(
        button: true,
        label: l10n.iotDemoAddDeviceTooltip,
        child: FloatingActionButton(
          onPressed: () => showIotDemoAddDeviceDialog(context),
          tooltip: l10n.iotDemoAddDeviceTooltip,
          child: const Icon(Icons.add),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TypeSafeBlocBuilder<IotDemoCubit, IotDemoState>(
            builder: (final context, final state) {
              return state.mapOrNull(
                    loaded: (final s) => Padding(
                      padding: context.pagePadding.copyWith(bottom: 0),
                      child: SegmentedButton<IotDemoDeviceFilter>(
                        segments: <ButtonSegment<IotDemoDeviceFilter>>[
                          ButtonSegment<IotDemoDeviceFilter>(
                            value: IotDemoDeviceFilter.all,
                            label: Text(l10n.iotDemoFilterAll),
                          ),
                          ButtonSegment<IotDemoDeviceFilter>(
                            value: IotDemoDeviceFilter.toggledOnOnly,
                            label: Text(l10n.iotDemoFilterOnOnly),
                          ),
                          ButtonSegment<IotDemoDeviceFilter>(
                            value: IotDemoDeviceFilter.toggledOffOnly,
                            label: Text(l10n.iotDemoFilterOffOnly),
                          ),
                        ],
                        selected: <IotDemoDeviceFilter>{s.filter},
                        onSelectionChanged: (final selected) {
                          final IotDemoDeviceFilter? f = selected.firstOrNull;
                          if (f != null && f != s.filter) {
                            context.cubit<IotDemoCubit>().setFilter(f);
                          }
                        },
                      ),
                    ),
                  ) ??
                  const SizedBox.shrink();
            },
          ),
          Expanded(
            child: TypeSafeBlocBuilder<IotDemoCubit, IotDemoState>(
              builder: (final context, final state) {
                return state.when(
                  initial: () => const IotDemoLoadingBody(),
                  loading: () => const IotDemoLoadingBody(),
                  loaded:
                      (final devices, final selectedDeviceId, final filter) =>
                          IotDemoLoadedBody(
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
