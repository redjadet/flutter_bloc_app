import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_device_filter.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device_command.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/cubit/iot_demo_cubit.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/cubit/iot_demo_state.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository.dart';
import 'package:flutter_test/flutter_test.dart';

const List<IotDevice> _fakeDevices = [
  IotDevice(id: 'dev-1', name: 'Test Device', type: IotDeviceType.light),
];

const List<IotDevice> _devicesWithToggle = [
  IotDevice(
    id: 'on-1',
    name: 'On Device',
    type: IotDeviceType.light,
    toggledOn: true,
  ),
  IotDevice(
    id: 'off-1',
    name: 'Off Device',
    type: IotDeviceType.plug,
    toggledOn: false,
  ),
];

class _StubIotDemoRepository implements IotDemoRepository {
  _StubIotDemoRepository({
    List<IotDevice>? devices,
    this.throwOnConnect = false,
    this.throwOnDisconnect = false,
    this.throwOnSendCommand = false,
    this.throwArgumentErrorOnAddDevice = false,
  }) : devices = devices ?? _fakeDevices;

  final List<IotDevice> devices;
  final bool throwOnConnect;
  final bool throwOnDisconnect;
  final bool throwOnSendCommand;
  final bool throwArgumentErrorOnAddDevice;
  final List<IotDemoDeviceFilter> watchFilters = <IotDemoDeviceFilter>[];
  int watchCallCount = 0;

  @override
  Stream<List<IotDevice>> watchDevices([
    final IotDemoDeviceFilter filter = IotDemoDeviceFilter.all,
  ]) {
    watchCallCount++;
    watchFilters.add(filter);
    return Stream<List<IotDevice>>.value(devices);
  }

  @override
  Future<void> connect(final String deviceId) async {
    if (throwOnConnect) throw Exception('connect failed');
  }

  @override
  Future<void> disconnect(final String deviceId) async {
    if (throwOnDisconnect) throw Exception('disconnect failed');
  }

  @override
  Future<void> sendCommand(
    final String deviceId,
    final IotDeviceCommand command,
  ) async {
    if (throwOnSendCommand) throw Exception('command failed');
  }

  @override
  Future<void> addDevice(final IotDevice device) async {
    if (throwArgumentErrorOnAddDevice) {
      throw ArgumentError('device name must not exceed 255 characters');
    }
  }
}

class _StreamingIotDemoRepository implements IotDemoRepository {
  _StreamingIotDemoRepository();

  final StreamController<List<IotDevice>> _controller =
      StreamController<List<IotDevice>>.broadcast();

  @override
  Stream<List<IotDevice>> watchDevices([
    final IotDemoDeviceFilter filter = IotDemoDeviceFilter.all,
  ]) => _controller.stream;

  void emit(final List<IotDevice> devices) {
    _controller.add(devices);
  }

  Future<void> dispose() async {
    await _controller.close();
  }

  @override
  Future<void> connect(final String deviceId) async {}

  @override
  Future<void> disconnect(final String deviceId) async {}

  @override
  Future<void> sendCommand(
    final String deviceId,
    final IotDeviceCommand command,
  ) async {}

  @override
  Future<void> addDevice(final IotDevice device) async {}
}

class _DelayedFilterRepository implements IotDemoRepository {
  _DelayedFilterRepository(this.devices);

  final List<IotDevice> devices;

  @override
  Stream<List<IotDevice>> watchDevices([
    final IotDemoDeviceFilter filter = IotDemoDeviceFilter.all,
  ]) async* {
    yield devices;
  }

  @override
  Future<void> connect(final String deviceId) async {}

  @override
  Future<void> disconnect(final String deviceId) async {}

  @override
  Future<void> sendCommand(
    final String deviceId,
    final IotDeviceCommand command,
  ) async {}

  @override
  Future<void> addDevice(final IotDevice device) async {}
}

class _PrewarmingSyncableRepository
    implements IotDemoRepository, SyncableRepository {
  _PrewarmingSyncableRepository({
    required List<IotDevice> initialDevices,
    required List<IotDevice> remoteDevices,
  }) : _devices = List<IotDevice>.from(initialDevices),
       _remoteDevices = List<IotDevice>.from(remoteDevices);

  List<IotDevice> _devices;
  final List<IotDevice> _remoteDevices;
  int pullRemoteCallCount = 0;

  @override
  Stream<List<IotDevice>> watchDevices([
    final IotDemoDeviceFilter filter = IotDemoDeviceFilter.all,
  ]) {
    return Stream<List<IotDevice>>.value(List<IotDevice>.from(_devices));
  }

  @override
  Future<void> pullRemote() async {
    pullRemoteCallCount++;
    _devices = List<IotDevice>.from(_remoteDevices);
  }

  @override
  String get entityType => 'iot_demo';

  @override
  Future<void> processOperation(final SyncOperation operation) async {}

  @override
  Future<void> connect(final String deviceId) async {}

  @override
  Future<void> disconnect(final String deviceId) async {}

  @override
  Future<void> sendCommand(
    final String deviceId,
    final IotDeviceCommand command,
  ) async {}

  @override
  Future<void> addDevice(final IotDevice device) async {}
}

void main() {
  group('IotDemoCubit', () {
    blocTest<IotDemoCubit, IotDemoState>(
      'emits [loading, loaded] when initialize succeeds',
      build: () => IotDemoCubit(repository: _StubIotDemoRepository()),
      act: (cubit) => cubit.initialize(),
      expect: () => <IotDemoState>[
        const IotDemoState.loading(),
        IotDemoState.loaded(_fakeDevices, selectedDeviceId: null),
      ],
    );

    test(
      'initialize prewarms syncable repositories when the first local snapshot is empty',
      () async {
        final _PrewarmingSyncableRepository repository =
            _PrewarmingSyncableRepository(
              initialDevices: const <IotDevice>[],
              remoteDevices: _fakeDevices,
            );
        final IotDemoCubit cubit = IotDemoCubit(repository: repository);
        addTearDown(cubit.close);

        final List<IotDemoState> emittedStates = <IotDemoState>[];
        final StreamSubscription<IotDemoState> subscription = cubit.stream
            .listen(emittedStates.add);
        addTearDown(subscription.cancel);

        await cubit.initialize();
        await Future<void>.delayed(Duration.zero);

        expect(repository.pullRemoteCallCount, 1);
        expect(emittedStates, <IotDemoState>[
          const IotDemoState.loading(),
          IotDemoState.loaded(_fakeDevices, selectedDeviceId: null),
        ]);
      },
    );

    blocTest<IotDemoCubit, IotDemoState>(
      'selectDevice updates selectedDeviceId when state is loaded',
      build: () => IotDemoCubit(repository: _StubIotDemoRepository()),
      act: (cubit) async {
        await cubit.initialize();
        await Future<void>.delayed(Duration.zero);
        cubit.selectDevice('dev-1');
      },
      expect: () => <IotDemoState>[
        const IotDemoState.loading(),
        IotDemoState.loaded(_fakeDevices, selectedDeviceId: null),
        IotDemoState.loaded(_fakeDevices, selectedDeviceId: 'dev-1'),
      ],
    );

    blocTest<IotDemoCubit, IotDemoState>(
      'connect does not emit error when repository succeeds',
      build: () => IotDemoCubit(repository: _StubIotDemoRepository()),
      act: (cubit) async {
        await cubit.initialize();
        await cubit.connect('dev-1');
      },
      expect: () => <IotDemoState>[
        const IotDemoState.loading(),
        IotDemoState.loaded(_fakeDevices, selectedDeviceId: null),
      ],
    );

    blocTest<IotDemoCubit, IotDemoState>(
      'emits error when connect throws',
      build: () => IotDemoCubit(
        repository: _StubIotDemoRepository(throwOnConnect: true),
      ),
      act: (cubit) async {
        await cubit.initialize();
        await cubit.connect('dev-1');
      },
      expect: () => <IotDemoState>[
        const IotDemoState.loading(),
        IotDemoState.loaded(_fakeDevices, selectedDeviceId: null),
        IotDemoState.error('Exception: connect failed'),
      ],
    );

    blocTest<IotDemoCubit, IotDemoState>(
      'emits error when sendCommand throws',
      build: () => IotDemoCubit(
        repository: _StubIotDemoRepository(throwOnSendCommand: true),
      ),
      act: (cubit) async {
        await cubit.initialize();
        await cubit.sendCommand('dev-1', const IotDeviceCommand.toggle());
      },
      expect: () => <IotDemoState>[
        const IotDemoState.loading(),
        IotDemoState.loaded(_fakeDevices, selectedDeviceId: null),
        IotDemoState.error('Exception: command failed'),
      ],
    );

    blocTest<IotDemoCubit, IotDemoState>(
      'emits error when disconnect throws',
      build: () => IotDemoCubit(
        repository: _StubIotDemoRepository(throwOnDisconnect: true),
      ),
      act: (cubit) async {
        await cubit.initialize();
        await cubit.disconnect('dev-1');
      },
      expect: () => <IotDemoState>[
        const IotDemoState.loading(),
        IotDemoState.loaded(_fakeDevices, selectedDeviceId: null),
        IotDemoState.error('Exception: disconnect failed'),
      ],
    );

    blocTest<IotDemoCubit, IotDemoState>(
      'emits validation message when addDevice throws ArgumentError',
      build: () => IotDemoCubit(
        repository: _StubIotDemoRepository(throwArgumentErrorOnAddDevice: true),
      ),
      act: (cubit) async {
        await cubit.initialize();
        await cubit.addDevice(
          IotDevice(id: 'new-1', name: 'x' * 300, type: IotDeviceType.light),
        );
      },
      expect: () => <IotDemoState>[
        const IotDemoState.loading(),
        IotDemoState.loaded(_fakeDevices, selectedDeviceId: null),
        IotDemoState.error('device name must not exceed 255 characters'),
      ],
    );

    final _StreamingIotDemoRepository streamingRepository =
        _StreamingIotDemoRepository();
    blocTest<IotDemoCubit, IotDemoState>(
      'setFilter resubscribes with filtered local data without loading',
      build: () => IotDemoCubit(
        repository: _StubIotDemoRepository(devices: _devicesWithToggle),
      ),
      act: (cubit) async {
        await cubit.initialize();
        await Future<void>.delayed(Duration.zero);
        cubit.setFilter(IotDemoDeviceFilter.toggledOnOnly);
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => <IotDemoState>[
        const IotDemoState.loading(),
        IotDemoState.loaded(
          _devicesWithToggle,
          selectedDeviceId: null,
          filter: IotDemoDeviceFilter.all,
        ),
        IotDemoState.loaded(
          _devicesWithToggle.where((d) => d.toggledOn).toList(),
          selectedDeviceId: null,
          filter: IotDemoDeviceFilter.toggledOnOnly,
        ),
      ],
    );

    blocTest<IotDemoCubit, IotDemoState>(
      'setFilter switches from onOnly to all without loading',
      build: () => IotDemoCubit(
        repository: _StubIotDemoRepository(devices: _devicesWithToggle),
      ),
      act: (cubit) async {
        await cubit.initialize();
        await Future<void>.delayed(Duration.zero);
        cubit.setFilter(IotDemoDeviceFilter.toggledOnOnly);
        await Future<void>.delayed(Duration.zero);
        cubit.setFilter(IotDemoDeviceFilter.all);
      },
      expect: () => <IotDemoState>[
        const IotDemoState.loading(),
        IotDemoState.loaded(
          _devicesWithToggle,
          selectedDeviceId: null,
          filter: IotDemoDeviceFilter.all,
        ),
        IotDemoState.loaded(
          _devicesWithToggle.where((d) => d.toggledOn).toList(),
          selectedDeviceId: null,
          filter: IotDemoDeviceFilter.toggledOnOnly,
        ),
        IotDemoState.loaded(
          _devicesWithToggle,
          selectedDeviceId: null,
          filter: IotDemoDeviceFilter.all,
        ),
      ],
    );

    test('setFilter does not resubscribe repository', () async {
      final _StubIotDemoRepository repository = _StubIotDemoRepository(
        devices: _devicesWithToggle,
      );
      final IotDemoCubit cubit = IotDemoCubit(repository: repository);
      addTearDown(cubit.close);

      await cubit.initialize();
      await Future<void>.delayed(Duration.zero);
      cubit.setFilter(IotDemoDeviceFilter.toggledOffOnly);
      await Future<void>.delayed(Duration.zero);

      expect(repository.watchFilters, <IotDemoDeviceFilter>[
        IotDemoDeviceFilter.all,
      ]);
      expect(repository.watchCallCount, 1);
    });

    blocTest<IotDemoCubit, IotDemoState>(
      'setFilter updates selected filter immediately before delayed data arrives',
      build: () => IotDemoCubit(
        repository: _DelayedFilterRepository(_devicesWithToggle),
      ),
      act: (cubit) async {
        await cubit.initialize();
        await Future<void>.delayed(Duration.zero);
        cubit.setFilter(IotDemoDeviceFilter.toggledOnOnly);
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => <IotDemoState>[
        const IotDemoState.loading(),
        IotDemoState.loaded(
          _devicesWithToggle,
          selectedDeviceId: null,
          filter: IotDemoDeviceFilter.all,
        ),
        IotDemoState.loaded(
          _devicesWithToggle.where((d) => d.toggledOn).toList(),
          selectedDeviceId: null,
          filter: IotDemoDeviceFilter.toggledOnOnly,
        ),
      ],
    );

    blocTest<IotDemoCubit, IotDemoState>(
      'stream updates keep the selected filter after remote-style refresh',
      build: () => IotDemoCubit(repository: streamingRepository),
      act: (final cubit) async {
        await cubit.initialize();
        streamingRepository.emit(_devicesWithToggle);
        await Future<void>.delayed(Duration.zero);
        cubit.setFilter(IotDemoDeviceFilter.toggledOnOnly);
        await Future<void>.delayed(Duration.zero);
        streamingRepository.emit(<IotDevice>[
          _devicesWithToggle.first,
          _devicesWithToggle[1],
          const IotDevice(
            id: 'on-2',
            name: 'Another On Device',
            type: IotDeviceType.sensor,
            toggledOn: true,
          ),
          const IotDevice(
            id: 'off-2',
            name: 'Another Off Device',
            type: IotDeviceType.sensor,
            toggledOn: false,
          ),
        ]);
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => <IotDemoState>[
        const IotDemoState.loading(),
        IotDemoState.loaded(
          _devicesWithToggle,
          selectedDeviceId: null,
          filter: IotDemoDeviceFilter.all,
        ),
        IotDemoState.loaded(
          _devicesWithToggle.where((d) => d.toggledOn).toList(),
          selectedDeviceId: null,
          filter: IotDemoDeviceFilter.toggledOnOnly,
        ),
        IotDemoState.loaded(
          <IotDevice>[
            _devicesWithToggle.first,
            const IotDevice(
              id: 'on-2',
              name: 'Another On Device',
              type: IotDeviceType.sensor,
              toggledOn: true,
            ),
          ],
          selectedDeviceId: null,
          filter: IotDemoDeviceFilter.toggledOnOnly,
        ),
      ],
    );

    blocTest<IotDemoCubit, IotDemoState>(
      'reinitialize does not duplicate stream emissions',
      build: () => IotDemoCubit(repository: streamingRepository),
      act: (final cubit) async {
        await cubit.initialize();
        streamingRepository.emit(_fakeDevices);
        await Future<void>.delayed(Duration.zero);
        await cubit.initialize();
        streamingRepository.emit(_fakeDevices);
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => <IotDemoState>[
        const IotDemoState.loading(),
        IotDemoState.loaded(_fakeDevices, selectedDeviceId: null),
        const IotDemoState.loading(),
        IotDemoState.loaded(_fakeDevices, selectedDeviceId: null),
      ],
      tearDown: () async {
        await streamingRepository.dispose();
      },
    );
  });
}
