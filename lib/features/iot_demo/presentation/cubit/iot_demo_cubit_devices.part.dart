part of 'iot_demo_cubit.dart';

extension _IotDemoCubitDevices on IotDemoCubit {
  Future<void> prewarmRemoteDevicesIfNeeded() async {
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
        'IotDemoCubit.prewarmRemoteDevicesIfNeeded',
        error,
        stackTrace,
      );
    }
  }

  Future<void> restartDevicesSubscriptionImpl({
    required final IotDemoDeviceFilter filter,
    final String? previousSelectedDeviceId,
    final bool emitLoadingState = false,
  }) async {
    final int requestId = ++_devicesWatchRequestId;
    if (emitLoadingState) {
      emitIotState(const IotDemoState.loading());
    }
    final StreamSubscription<List<IotDevice>>? previousSubscription =
        _devicesSubscription;
    _devicesSubscription = null;
    await cancelRegisteredSubscription(previousSubscription);
    if (isClosed || requestId != _devicesWatchRequestId) return;
    subscribeToDevicesImpl(filter, previousSelectedDeviceId, requestId);
  }

  void subscribeToDevicesImpl(
    final IotDemoDeviceFilter filter,
    final String? previousSelectedDeviceId,
    final int requestId,
  ) {
    _devicesSubscription = registerSubscription(
      _repository.watchDevices().listen(
        (final list) {
          if (isClosed || requestId != _devicesWatchRequestId) return;
          _allDevices = List<IotDevice>.unmodifiable(list);
          final IotDemoDeviceFilter activeFilter =
              state.mapOrNull(loaded: (final s) => s.filter) ?? filter;
          emitIotState(
            buildLoadedStateImpl(
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
          emitIotState(
            IotDemoState.error(_l10n?.iotDemoErrorLoad ?? error.toString()),
          );
        },
        cancelOnError: true,
      ),
    );
  }

  IotDemoState buildLoadedStateImpl({
    required final List<IotDevice> devices,
    required final IotDemoDeviceFilter filter,
    required final String? selectedDeviceId,
  }) {
    final List<IotDevice> filteredDevices = applyFilterImpl(devices, filter);
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

  List<IotDevice> applyFilterImpl(
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
}
