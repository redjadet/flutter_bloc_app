import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/router/pages/iot_demo_hub_page.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/register_iot_services.dart';
import 'package:flutter_bloc_app/core/theme/mix_app_theme.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_device_filter.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device_command.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/cubit/iot_demo_cubit.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
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
}
