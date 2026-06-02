import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_device_filter.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device_command.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/cubit/iot_demo_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_subscription_mixin.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

part 'iot_demo_cubit_devices.part.dart';

/// Cubit for the IoT demo: list devices, connect, disconnect, send commands.
class IotDemoCubit extends Cubit<IotDemoState>
    with CubitSubscriptionMixin<IotDemoState> {
  IotDemoCubit({
    required this._repository,
    this._l10n,
  }) : super(const IotDemoState.initial());

  final IotDemoRepository _repository;
  final AppLocalizations? _l10n;
  // ignore: cancel_subscriptions - Subscription is managed by CubitSubscriptionMixin.
  StreamSubscription<List<IotDevice>>? _devicesSubscription;
  int _devicesWatchRequestId = 0;
  List<IotDevice> _allDevices = const <IotDevice>[];

  /// Subscribe to device stream and emit initial/loading then loaded states.
  /// Uses [filterOverride] when provided, else filter from loaded state, else all.
  Future<void> initialize({final IotDemoDeviceFilter? filterOverride}) async {
    if (isClosed) return;
    final String? previousSelectedDeviceId = state.mapOrNull(
      loaded: (final s) => s.selectedDeviceId,
    );
    final IotDemoDeviceFilter filter =
        filterOverride ??
        state.mapOrNull(loaded: (final s) => s.filter) ??
        IotDemoDeviceFilter.all;
    await prewarmRemoteDevicesIfNeeded();
    if (isClosed) return;
    await restartDevicesSubscriptionImpl(
      filter: filter,
      previousSelectedDeviceId: previousSelectedDeviceId,
      emitLoadingState: true,
    );
  }

  void setFilter(final IotDemoDeviceFilter filter) {
    if (isClosed) return;
    state.mapOrNull(
      loaded: (final s) {
        if (s.filter == filter) return;
        emit(
          buildLoadedStateImpl(
            devices: _allDevices,
            filter: filter,
            selectedDeviceId: s.selectedDeviceId,
          ),
        );
      },
    );
  }

  void selectDevice(final String? deviceId) {
    if (isClosed) return;
    state.mapOrNull(
      loaded: (final s) => emit(s.copyWith(selectedDeviceId: deviceId)),
    );
  }

  Future<void> connect(final String deviceId) async {
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () => _repository.connect(deviceId),
      isAlive: () => !isClosed,
      onError: (final message) {
        if (isClosed) return;
        emit(
          IotDemoState.error(
            _l10n?.iotDemoErrorConnect ?? message,
          ),
        );
      },
      logContext: 'IotDemoCubit.connect',
    );
  }

  Future<void> disconnect(final String deviceId) async {
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () => _repository.disconnect(deviceId),
      isAlive: () => !isClosed,
      onError: (final message) {
        if (isClosed) return;
        emit(
          IotDemoState.error(
            _l10n?.iotDemoErrorDisconnect ?? message,
          ),
        );
      },
      logContext: 'IotDemoCubit.disconnect',
    );
  }

  Future<void> sendCommand(
    final String deviceId,
    final IotDeviceCommand command,
  ) async {
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () => _repository.sendCommand(deviceId, command),
      isAlive: () => !isClosed,
      onError: (final message) {
        if (isClosed) return;
        emit(
          IotDemoState.error(
            _l10n?.iotDemoErrorCommand ?? message,
          ),
        );
      },
      logContext: 'IotDemoCubit.sendCommand',
    );
  }

  Future<void> addDevice(final IotDevice device) async {
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () => _repository.addDevice(device),
      isAlive: () => !isClosed,
      onError: (final message) {
        if (isClosed) return;
        emit(
          IotDemoState.error(
            _l10n?.iotDemoErrorAdd ?? message,
          ),
        );
      },
      logContext: 'IotDemoCubit.addDevice',
      specificExceptionHandlers: <Type, void Function(Object, StackTrace?)>{
        ArgumentError: (final error, final _) {
          if (isClosed) return;
          final String msg =
              ((error as ArgumentError).message as String?) ?? error.toString();
          emit(
            IotDemoState.error(
              msg.isNotEmpty
                  ? msg
                  : (_l10n?.iotDemoErrorAdd ?? error.toString()),
            ),
          );
        },
      },
    );
  }

  void emitIotState(final IotDemoState value) => emit(value);

  @override
  Future<void> close() {
    _devicesSubscription = null;
    return super.close();
  }
}
