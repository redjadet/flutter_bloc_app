import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_device_filter.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/cubit/iot_demo_cubit.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/cubit/iot_demo_state.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/pages/iot_demo_error_messages.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/pages/iot_demo_page_body.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/pages/iot_demo_page_helpers.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';

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
      body: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _IotDemoFilterSection(),
          Expanded(
            child: _IotDemoBodySection(),
          ),
        ],
      ),
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
            loaded:
                (
                  final devices,
                  final selectedDeviceId,
                  final filter,
                ) => (
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
