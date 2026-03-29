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
    await _prewarmRemoteDevicesIfNeeded();
    if (isClosed) return;
    await _restartDevicesSubscription(
      filter: filter,
      previousSelectedDeviceId: previousSelectedDeviceId,
      emitLoadingState: true,
    );
  }

  Future<void> _prewarmRemoteDevicesIfNeeded() async {
    final SyncableRepository? syncable = switch (_repository) {
      final SyncableRepository value => value,
      _ => null,
    };
    if (syncable == null) {
      return;
    }

    try {
      final List<IotDevice> initialDevices = await _repository
          .watchDevices()
          .first;
      if (isClosed || initialDevices.isNotEmpty) {
        return;
      }
      await syncable.pullRemote();
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'IotDemoCubit._prewarmRemoteDevicesIfNeeded',
        error,
        stackTrace,
      );
    }
  }

  void setFilter(final IotDemoDeviceFilter filter) {
    if (isClosed) return;
    state.mapOrNull(
      loaded: (final s) {
        if (s.filter == filter) return;
        emit(
          _buildLoadedState(
            devices: _allDevices,
            filter: filter,
            selectedDeviceId: s.selectedDeviceId,
          ),
        );
      },
    );
  }

  Future<void> _restartDevicesSubscription({
    required final IotDemoDeviceFilter filter,
    final String? previousSelectedDeviceId,
    final bool emitLoadingState = false,
  }) async {
    final int requestId = ++_devicesWatchRequestId;
    if (emitLoadingState) {
      emit(const IotDemoState.loading());
    }
    await cancelAllSubscriptions();
    if (isClosed || requestId != _devicesWatchRequestId) return;
    _subscribeToDevices(filter, previousSelectedDeviceId, requestId);
  }

  void _subscribeToDevices(
    final IotDemoDeviceFilter filter,
    final String? previousSelectedDeviceId,
    final int requestId,
  ) {
    _devicesSubscription = _repository.watchDevices().listen(
      (final list) {
        if (isClosed || requestId != _devicesWatchRequestId) return;
        _allDevices = List<IotDevice>.unmodifiable(list);
        final IotDemoDeviceFilter activeFilter =
            state.mapOrNull(loaded: (final s) => s.filter) ?? filter;
        emit(
          _buildLoadedState(
            devices: list,
            filter: activeFilter,
            selectedDeviceId:
                state.mapOrNull(loaded: (final s) => s.selectedDeviceId) ??
                previousSelectedDeviceId,
          ),
        );
      },
      onError: (final Object error, final StackTrace stackTrace) {
        AppLogger.error(
          'IotDemoCubit watchDevices error',
          error,
          stackTrace,
        );
        if (isClosed || requestId != _devicesWatchRequestId) return;
        emit(
          IotDemoState.error(_l10n?.iotDemoErrorLoad ?? error.toString()),
        );
      },
      cancelOnError: true,
    );
    registerSubscription(_devicesSubscription);
  }

  IotDemoState _buildLoadedState({
    required final List<IotDevice> devices,
    required final IotDemoDeviceFilter filter,
    required final String? selectedDeviceId,
  }) {
    final List<IotDevice> filteredDevices = _applyFilter(devices, filter);
    final String? resolvedSelection =
        selectedDeviceId != null &&
            filteredDevices.any((final d) => d.id == selectedDeviceId)
        ? selectedDeviceId
        : null;
    return IotDemoState.loaded(
      filteredDevices,
      selectedDeviceId: resolvedSelection,
      filter: filter,
    );
  }

  List<IotDevice> _applyFilter(
    final List<IotDevice> devices,
    final IotDemoDeviceFilter filter,
  ) {
    switch (filter) {
      case IotDemoDeviceFilter.all:
        return devices;
      case IotDemoDeviceFilter.toggledOnOnly:
        return devices.where((final d) => d.toggledOn).toList();
      case IotDemoDeviceFilter.toggledOffOnly:
        return devices.where((final d) => !d.toggledOn).toList();
    }
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

  @override
  Future<void> close() {
    _devicesSubscription = null;
    return super.close();
  }
}
