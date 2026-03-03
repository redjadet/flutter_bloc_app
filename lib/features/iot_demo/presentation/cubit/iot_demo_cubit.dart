import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device_command.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/cubit/iot_demo_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_subscription_mixin.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Cubit for the IoT demo: list devices, connect, disconnect, send commands.
class IotDemoCubit extends Cubit<IotDemoState>
    with CubitSubscriptionMixin<IotDemoState> {
  IotDemoCubit({
    required final IotDemoRepository repository,
    final AppLocalizations? l10n,
  }) : _repository = repository,
       _l10n = l10n,
       super(const IotDemoState.initial());

  final IotDemoRepository _repository;
  final AppLocalizations? _l10n;
  // ignore: cancel_subscriptions - Subscription is managed by CubitSubscriptionMixin.
  StreamSubscription<List<IotDevice>>? _devicesSubscription;

  /// Subscribe to device stream and emit initial/loading then loaded states.
  Future<void> initialize() async {
    if (isClosed) return;
    final String? previousSelectedDeviceId = state.mapOrNull(
      loaded: (final s) => s.selectedDeviceId,
    );
    emit(const IotDemoState.loading());
    await cancelAllSubscriptions();
    if (isClosed) return;

    _devicesSubscription = _repository.watchDevices().listen(
      (final list) {
        if (isClosed) return;
        final String? selected =
            state.mapOrNull(loaded: (final s) => s.selectedDeviceId) ??
            previousSelectedDeviceId;
        final String? resolvedSelection =
            selected != null && list.any((final d) => d.id == selected)
            ? selected
            : null;
        emit(
          IotDemoState.loaded(
            list,
            selectedDeviceId: resolvedSelection,
          ),
        );
      },
      onError: (final Object error, final StackTrace stackTrace) {
        AppLogger.error(
          'IotDemoCubit watchDevices error',
          error,
          stackTrace,
        );
        if (isClosed) return;
        emit(IotDemoState.error(_l10n?.iotDemoErrorLoad ?? error.toString()));
      },
      cancelOnError: true,
    );
    registerSubscription(_devicesSubscription);
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

  @override
  Future<void> close() {
    _devicesSubscription = null;
    return super.close();
  }
}
