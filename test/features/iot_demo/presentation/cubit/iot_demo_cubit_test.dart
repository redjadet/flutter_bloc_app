import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device_command.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/cubit/iot_demo_cubit.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/cubit/iot_demo_state.dart';
import 'package:flutter_test/flutter_test.dart';

const List<IotDevice> _fakeDevices = [
  IotDevice(id: 'dev-1', name: 'Test Device', type: IotDeviceType.light),
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

  @override
  Stream<List<IotDevice>> watchDevices() =>
      Stream<List<IotDevice>>.fromIterable([devices]);

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
  Stream<List<IotDevice>> watchDevices() => _controller.stream;

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
      build: () =>
          IotDemoCubit(repository: _StubIotDemoRepository(throwArgumentErrorOnAddDevice: true)),
      act: (cubit) async {
        await cubit.initialize();
        await cubit.addDevice(IotDevice(id: 'new-1', name: 'x' * 300, type: IotDeviceType.light));
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
