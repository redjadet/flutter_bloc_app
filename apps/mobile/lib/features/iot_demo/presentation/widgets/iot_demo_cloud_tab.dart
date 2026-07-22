import 'package:design_system/design_system.dart';
import 'package:design_system/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/app/widgets/backend_disabled_banner.dart';
import 'package:flutter_bloc_app/app/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_device_filter.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/cubit/iot_demo_cubit.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/cubit/iot_demo_state.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/pages/iot_demo_error_messages.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/pages/iot_demo_page_body.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';

/// Cloud IoT tab content extracted for the IoT demo hub (no BLE imports).
class IotDemoCloudTab extends StatefulWidget {
  const IotDemoCloudTab({required this.showBackendDisabledBanner, super.key});

  final bool showBackendDisabledBanner;

  @override
  State<IotDemoCloudTab> createState() => _IotDemoCloudTabState();
}

class _IotDemoCloudTabState extends State<IotDemoCloudTab> {
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        BackendDisabledBanner(visible: widget.showBackendDisabledBanner),
        const _IotDemoFilterSection(),
        const Expanded(child: _IotDemoBodySection()),
      ],
    );
  }
}

class _IotDemoFilterSection extends StatelessWidget {
  const _IotDemoFilterSection();

  @override
  Widget build(final BuildContext context) {
    final filter = context
        .selectState<IotDemoCubit, IotDemoState, IotDemoDeviceFilter?>(
          selector: (final state) => state.mapOrNull(
            loaded: (final state) => state.filter,
          ),
        );

    if (filter == null) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;
    return Padding(
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
        selected: <IotDemoDeviceFilter>{filter},
        onSelectionChanged: (final selected) {
          final IotDemoDeviceFilter? nextFilter = selected.firstOrNull;
          if (nextFilter != null && nextFilter != filter) {
            context.cubit<IotDemoCubit>().setFilter(nextFilter);
          }
        },
      ),
    );
  }
}

class _IotDemoBodySection extends StatelessWidget {
  const _IotDemoBodySection();

  @override
  Widget build(final BuildContext context) {
    final viewState = context
        .selectState<
          IotDemoCubit,
          IotDemoState,
          ({
            bool isLoading,
            List<IotDevice>? devices,
            String? selectedDeviceId,
            String? errorMessage,
          })
        >(
          selector: (final state) => state.when(
            initial: () => (
              isLoading: true,
              devices: null,
              selectedDeviceId: null,
              errorMessage: null,
            ),
            loading: () => (
              isLoading: true,
              devices: null,
              selectedDeviceId: null,
              errorMessage: null,
            ),
            loaded: (final devices, final selectedDeviceId, final filter) => (
              isLoading: false,
              devices: devices,
              selectedDeviceId: selectedDeviceId,
              errorMessage: null,
            ),
            error: (final code, final detail) => (
              isLoading: false,
              devices: null,
              selectedDeviceId: null,
              errorMessage: resolveIotDemoErrorMessage(
                context.l10n,
                code,
                detail,
              ),
            ),
          ),
        );

    if (viewState.isLoading) {
      return const IotDemoLoadingBody();
    }
    if (viewState.errorMessage case final message?) {
      return CommonErrorView(
        message: message,
        onRetry: () => context.cubit<IotDemoCubit>().initialize(),
      );
    }

    return IotDemoLoadedBody(
      devices: viewState.devices ?? const <IotDevice>[],
      selectedDeviceId: viewState.selectedDeviceId,
    );
  }
}
