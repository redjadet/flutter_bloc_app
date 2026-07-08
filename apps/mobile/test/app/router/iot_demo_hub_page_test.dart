import 'dart:async';
import 'package:core/core.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/router/pages/iot_demo_hub_page.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/features/register_iot_services.dart';
import 'package:flutter_bloc_app/app/theme/theme.dart';
import 'package:flutter_bloc_app/features/iot/data/mock_ble_repository.dart';
import 'package:flutter_bloc_app/features/iot/data/mock_classic_bluetooth_repository.dart';
import 'package:flutter_bloc_app/features/iot/presentation/cubit/iot_ble_cubit.dart';
import 'package:flutter_bloc_app/features/iot/presentation/widgets/iot_ble_section.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_device_filter.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device_command.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/cubit/iot_demo_cubit.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:networking/networking.dart';
import 'package:flutter_bloc_app/app/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubIotDemoRepository implements IotDemoRepository {
  @override
  Stream<List<IotDevice>> watchDevices([
    final IotDemoDeviceFilter filter = IotDemoDeviceFilter.all,
  ]) => Stream<List<IotDevice>>.value(const <IotDevice>[]);

  @override
  Future<void> addDevice(final IotDevice device) async {}

  @override
  Future<void> connect(final String deviceId) async {}

  @override
  Future<void> disconnect(final String deviceId) async {}

  @override
  Future<void> sendCommand(
    final String deviceId,
    final IotDeviceCommand command,
  ) async {}
}

class _FakeNetworkStatusService implements NetworkStatusService {
  @override
  Stream<NetworkStatus> get statusStream => const Stream<NetworkStatus>.empty();

  @override
  Future<NetworkStatus> getCurrentStatus() async => NetworkStatus.online;

  @override
  Future<void> dispose() async {}
}

class _FakeBackgroundSyncCoordinator implements BackgroundSyncCoordinator {
  @override
  Stream<SyncStatus> get statusStream => const Stream<SyncStatus>.empty();

  @override
  SyncStatus get currentStatus => SyncStatus.idle;

  @override
  List<SyncCycleSummary> get history => const <SyncCycleSummary>[];

  @override
  Stream<SyncCycleSummary> get summaryStream =>
      const Stream<SyncCycleSummary>.empty();

  @override
  SyncCycleSummary? get latestSummary => null;

  @override
  Future<void> start() async {}

  @override
  Future<void> ensureStarted() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> flush() async {}

  @override
  Future<void> triggerFromFcm({final String? hint}) async {}
}

class _TrackingBleRepository extends MockBleRepository {
  int stopScanCalls = 0;
  int disconnectCalls = 0;

  @override
  Future<void> stopScan() async {
    stopScanCalls += 1;
    await super.stopScan();
  }

  @override
  Future<void> disconnect() async {
    disconnectCalls += 1;
    await super.disconnect();
  }
}

class _TrackingClassicRepository extends MockClassicBluetoothRepository {
  int disconnectCalls = 0;

  @override
  Future<void> disconnect() async {
    disconnectCalls += 1;
    await super.disconnect();
  }
}

void main() {
  setUp(() {
    if (!getIt.isRegistered<TimerService>()) {
      getIt.registerLazySingleton<TimerService>(DefaultTimerService.new);
    }
    registerIotServices();
  });

  tearDown(() async {
    await getIt.reset(dispose: true);
  });

  testWidgets('IotDemoHubPage shows Cloud and BLE tabs', (final tester) async {
    final IotDemoCubit demoCubit = IotDemoCubit(
      repository: _StubIotDemoRepository(),
    );
    addTearDown(demoCubit.close);
    final SyncStatusCubit syncCubit = SyncStatusCubit(
      networkStatusService: _FakeNetworkStatusService(),
      coordinator: _FakeBackgroundSyncCoordinator(),
    );
    addTearDown(syncCubit.close);

    await demoCubit.initialize();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Builder(
          builder: (final context) => buildAppMixScope(
            context,
            child: BlocProvider<SyncStatusCubit>.value(
              value: syncCubit,
              child: BlocProvider<IotDemoCubit>.value(
                value: demoCubit,
                child: const IotDemoHubPage(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text(AppLocalizationsEn().iotDemoHubTabCloud), findsOneWidget);
    await tester.tap(find.text(AppLocalizationsEn().iotDemoHubTabBle));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text(AppLocalizationsEn().iotBleStatusTitle), findsOneWidget);
  });

  testWidgets('leaving BLE tab tears down scan and Bluetooth sessions', (
    final tester,
  ) async {
    await getIt.unregister<MockBleRepository>();
    await getIt.unregister<MockClassicBluetoothRepository>();
    final _TrackingBleRepository bleRepository = _TrackingBleRepository();
    final _TrackingClassicRepository classicRepository =
        _TrackingClassicRepository();
    getIt.registerSingleton<MockBleRepository>(
      bleRepository,
      dispose: (final repository) => repository.dispose(),
    );
    getIt.registerSingleton<MockClassicBluetoothRepository>(
      classicRepository,
      dispose: (final repository) => repository.dispose(),
    );

    final IotDemoCubit demoCubit = IotDemoCubit(
      repository: _StubIotDemoRepository(),
    );
    addTearDown(demoCubit.close);
    final SyncStatusCubit syncCubit = SyncStatusCubit(
      networkStatusService: _FakeNetworkStatusService(),
      coordinator: _FakeBackgroundSyncCoordinator(),
    );
    addTearDown(syncCubit.close);

    await demoCubit.initialize();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Builder(
          builder: (final context) => buildAppMixScope(
            context,
            child: BlocProvider<SyncStatusCubit>.value(
              value: syncCubit,
              child: BlocProvider<IotDemoCubit>.value(
                value: demoCubit,
                child: const IotDemoHubPage(),
              ),
            ),
          ),
        ),
      ),
    );

    final AppLocalizationsEn l10n = AppLocalizationsEn();
    await tester.tap(find.text(l10n.iotDemoHubTabBle));
    await tester.pumpAndSettle();
    final BuildContext bleContext = tester.element(find.byType(IotBleSection));
    final IotBleCubit cubit = BlocProvider.of<IotBleCubit>(bleContext);
    await cubit.startScan();
    await cubit.connectClassicDevice('classic-speaker');
    final int stopScanCallsBeforeSwitch = bleRepository.stopScanCalls;
    final int disconnectCallsBeforeSwitch = bleRepository.disconnectCalls;

    await tester.tap(find.text(l10n.iotDemoHubTabCloud));
    await tester.pumpAndSettle();

    expect(bleRepository.stopScanCalls, greaterThan(stopScanCallsBeforeSwitch));
    expect(
      bleRepository.disconnectCalls,
      greaterThan(disconnectCallsBeforeSwitch),
    );
    expect(classicRepository.disconnectCalls, 1);
  });
}
