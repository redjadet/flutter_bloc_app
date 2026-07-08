import 'package:design_system/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/app/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/features/iot/domain/iot_ble_error_code.dart';
import 'package:flutter_bloc_app/features/iot/presentation/cubit/iot_ble_cubit.dart';
import 'package:flutter_bloc_app/features/iot/presentation/cubit/iot_ble_state.dart';
import 'package:flutter_bloc_app/features/iot/presentation/mappers/iot_ble_error_message_mapper.dart';
import 'package:flutter_bloc_app/features/iot/presentation/widgets/iot_ble_characteristics_explorer.dart';
import 'package:flutter_bloc_app/features/iot/presentation/widgets/iot_ble_classic_section.dart';
import 'package:flutter_bloc_app/features/iot/presentation/widgets/iot_ble_connected_panel.dart';
import 'package:flutter_bloc_app/features/iot/presentation/widgets/iot_ble_device_list.dart';
import 'package:flutter_bloc_app/features/iot/presentation/widgets/iot_ble_event_log_panel.dart';
import 'package:flutter_bloc_app/features/iot/presentation/widgets/iot_ble_read_write_panel.dart';
import 'package:flutter_bloc_app/features/iot/presentation/widgets/iot_ble_scan_controls.dart';
import 'package:flutter_bloc_app/features/iot/presentation/widgets/iot_ble_services_explorer.dart';
import 'package:flutter_bloc_app/features/iot/presentation/widgets/iot_ble_status_card.dart';

/// Scrollable BLE showcase mounted on the IoT demo hub BLE tab.
class IotBleSection extends StatelessWidget {
  const IotBleSection({super.key});

  @override
  Widget build(final BuildContext context) {
    final IotBleState state = context.watchState<IotBleCubit, IotBleState>();
    if (state.status == IotBleStatus.loading ||
        state.status == IotBleStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }
    final IotBleErrorCode? errorCode = state.errorCode;
    if (state.status == IotBleStatus.error && errorCode != null) {
      return CommonErrorView(
        message: resolveIotBleErrorMessage(
          context.l10n,
          errorCode,
          state.errorDetail,
        ),
        onRetry: context.cubit<IotBleCubit>().recoverFromBleError,
      );
    }
    return LayoutBuilder(
      builder: (final context, final constraints) {
        final bool wide = context.isMediumWidth;
        const Widget leftColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            IotBleStatusCard(),
            SizedBox(height: 12),
            IotBleScanControls(),
            SizedBox(height: 12),
            IotBleDeviceList(),
            SizedBox(height: 12),
            IotBleEventLogPanel(),
          ],
        );
        const Widget rightColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            IotBleConnectedPanel(),
            SizedBox(height: 12),
            IotBleServicesExplorer(),
            SizedBox(height: 12),
            IotBleCharacteristicsExplorer(),
            SizedBox(height: 12),
            IotBleReadWritePanel(),
            SizedBox(height: 12),
            IotBleClassicSection(),
          ],
        );
        return SingleChildScrollView(
          padding: context.pagePadding,
          child: wide
              ? const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(child: leftColumn),
                    SizedBox(width: 16),
                    Expanded(child: rightColumn),
                  ],
                )
              : const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    leftColumn,
                    SizedBox(height: 12),
                    rightColumn,
                  ],
                ),
        );
      },
    );
  }
}
