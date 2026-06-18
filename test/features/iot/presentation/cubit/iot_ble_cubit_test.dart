import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/core/config/iot_ble_runtime_config.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/iot/data/ble_platform_gateway_impl.dart';
import 'package:flutter_bloc_app/features/iot/data/mock_ble_device_catalog.dart';
import 'package:flutter_bloc_app/features/iot/data/mock_ble_repository.dart';
import 'package:flutter_bloc_app/features/iot/data/mock_classic_bluetooth_repository.dart';
import 'package:flutter_bloc_app/features/iot/data/unsupported_ble_repository.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_platform_gateway.dart';
import 'package:flutter_bloc_app/features/iot/domain/iot_ble_error_code.dart';
import 'package:flutter_bloc_app/features/iot/presentation/cubit/iot_ble_cubit.dart';
import 'package:flutter_bloc_app/features/iot/presentation/cubit/iot_ble_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _ImmediateTimerService implements TimerService {
  @override
  TimerDisposable periodic(
    final Duration interval,
    final void Function() onTick,
  ) => _NoopDisposable();

  @override
  TimerDisposable runOnce(
    final Duration delay,
    final void Function() onComplete,
  ) {
    onComplete();
    return _NoopDisposable();
  }
}

class _DeferredTimerService implements TimerService {
  @override
  TimerDisposable periodic(
    final Duration interval,
    final void Function() onTick,
  ) => _NoopDisposable();

  @override
  TimerDisposable runOnce(
    final Duration delay,
    final void Function() onComplete,
  ) => _NoopDisposable();
}

class _NoopDisposable with TimerDisposable {
  @override
  void dispose() {}
}

class _ManualTimerService implements TimerService {
  final List<_ManualTimerDisposable> handles = <_ManualTimerDisposable>[];

  @override
  TimerDisposable periodic(final Duration interval, final void Function() onTick) =>
      _NoopDisposable();

  @override
  TimerDisposable runOnce(final Duration delay, final void Function() onComplete) {
    final handle = _ManualTimerDisposable(onComplete);
    handles.add(handle);
    return handle;
  }
}

class _ManualTimerDisposable with TimerDisposable {
  _ManualTimerDisposable(this._onComplete);

  final void Function() _onComplete;
  bool disposed = false;

  void fire() {
    if (!disposed) {
      _onComplete();
    }
  }

  @override
  void dispose() {
    disposed = true;
  }
}

class _SupportsRealBleGateway implements BlePlatformGateway {
  @override
  bool get supportsRealBle => true;

  @override
  bool get supportsRealClassic => false;
}

void main() {
  late MockBleRepository mockRepository;
  late MockClassicBluetoothRepository classicRepository;

  setUp(() {
    mockRepository = MockBleRepository();
    classicRepository = MockClassicBluetoothRepository();
  });

  tearDown(() {
    mockRepository.dispose();
    classicRepository.dispose();
  });

  blocTest<IotBleCubit, IotBleState>(
    'initialize reaches ready in mock mode',
    build: () => IotBleCubit(
      mockRepository: mockRepository,
      reactiveRepository: const UnsupportedBleRepository(),
      classicRepository: classicRepository,
      platformGateway: const BlePlatformGatewayImpl(),
      runtimeConfig: const IotBleRuntimeConfig(defaultMockMode: true),
      timerService: _ImmediateTimerService(),
    ),
    act: (final cubit) => cubit.initialize(),
    verify: (final cubit) {
      expect(cubit.state.status, IotBleStatus.ready);
      expect(cubit.state.useMockBle, isTrue);
    },
  );

  blocTest<IotBleCubit, IotBleState>(
    'startScan populates devices in mock mode',
    build: () => IotBleCubit(
      mockRepository: mockRepository,
      reactiveRepository: const UnsupportedBleRepository(),
      classicRepository: classicRepository,
      platformGateway: const BlePlatformGatewayImpl(),
      runtimeConfig: const IotBleRuntimeConfig(defaultMockMode: true),
      timerService: _DeferredTimerService(),
    ),
    act: (final cubit) async {
      await cubit.initialize();
      await cubit.startScan();
      await Future<void>.delayed(const Duration(milliseconds: 100));
    },
    verify: (final cubit) {
      expect(cubit.state.isScanning, isTrue);
      expect(cubit.state.devices, isNotEmpty);
    },
  );

  blocTest<IotBleCubit, IotBleState>(
    'toggleBleMode to real surfaces unsupported platform error',
    build: () => IotBleCubit(
      mockRepository: mockRepository,
      reactiveRepository: const UnsupportedBleRepository(),
      classicRepository: classicRepository,
      platformGateway: _SupportsRealBleGateway(),
      runtimeConfig: const IotBleRuntimeConfig(defaultMockMode: true),
      timerService: _DeferredTimerService(),
    ),
    act: (final cubit) async {
      await cubit.initialize();
      await cubit.toggleBleMode(useMock: false);
    },
    verify: (final cubit) {
      expect(cubit.state.useMockBle, isFalse);
      expect(cubit.state.status, IotBleStatus.error);
      expect(cubit.state.errorCode, IotBleErrorCode.unsupportedPlatform);
    },
  );

  blocTest<IotBleCubit, IotBleState>(
    'recoverFromBleError switches back to mock after unsupported platform',
    build: () => IotBleCubit(
      mockRepository: mockRepository,
      reactiveRepository: const UnsupportedBleRepository(),
      classicRepository: classicRepository,
      platformGateway: _SupportsRealBleGateway(),
      runtimeConfig: const IotBleRuntimeConfig(defaultMockMode: true),
      timerService: _DeferredTimerService(),
    ),
    act: (final cubit) async {
      await cubit.initialize();
      await cubit.toggleBleMode(useMock: false);
      await cubit.recoverFromBleError();
    },
    verify: (final cubit) {
      expect(cubit.state.useMockBle, isTrue);
      expect(cubit.state.status, IotBleStatus.ready);
      expect(cubit.state.errorCode, isNull);
    },
  );

  blocTest<IotBleCubit, IotBleState>(
    'reconnect reuses connected session coordinator',
    build: () => IotBleCubit(
      mockRepository: mockRepository,
      reactiveRepository: const UnsupportedBleRepository(),
      classicRepository: classicRepository,
      platformGateway: const BlePlatformGatewayImpl(),
      runtimeConfig: const IotBleRuntimeConfig(defaultMockMode: true),
      timerService: _DeferredTimerService(),
    ),
    act: (final cubit) async {
      await cubit.initialize();
      await cubit.connect(MockBleDeviceCatalog.esp32Id);
      await cubit.reconnect();
    },
    verify: (final cubit) {
      expect(cubit.state.errorCode, isNull);
      expect(cubit.state.services, isNotEmpty);
      expect(cubit.state.isConnected, isTrue);
    },
  );

  test('stale scan timeout does not stop a later scan', () async {
    final timerService = _ManualTimerService();
    final cubit = IotBleCubit(
      mockRepository: mockRepository,
      reactiveRepository: const UnsupportedBleRepository(),
      classicRepository: classicRepository,
      platformGateway: const BlePlatformGatewayImpl(),
      runtimeConfig: const IotBleRuntimeConfig(defaultMockMode: true),
      timerService: timerService,
    );
    addTearDown(cubit.close);

    await cubit.initialize();
    await cubit.startScan();
    expect(cubit.state.isScanning, isTrue);
    expect(timerService.handles, hasLength(1));

    await cubit.stopScan();
    expect(timerService.handles.single.disposed, isTrue);

    await cubit.startScan();
    timerService.handles.first.fire();

    expect(cubit.state.isScanning, isTrue);
  });
}
