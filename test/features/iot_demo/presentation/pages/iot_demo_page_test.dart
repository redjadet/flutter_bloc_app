import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/theme/mix_app_theme.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_device_filter.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device_command.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/cubit/iot_demo_cubit.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/cubit/iot_demo_state.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/pages/iot_demo_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mix/mix.dart';

class _StubIotDemoRepository implements IotDemoRepository {
  _StubIotDemoRepository({this.devices = const <IotDevice>[]});

  final List<IotDevice> devices;

  @override
  Stream<List<IotDevice>> watchDevices([
    final IotDemoDeviceFilter filter = IotDemoDeviceFilter.all,
  ]) => Stream<List<IotDevice>>.value(devices);

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

class _TestIotDemoCubit extends IotDemoCubit {
  _TestIotDemoCubit() : super(repository: _StubIotDemoRepository());

  void setTestState(final IotDemoState value) => emit(value);
}

class _FakeNetworkStatusService implements NetworkStatusService {
  _FakeNetworkStatusService() : status = NetworkStatus.online;

  NetworkStatus status;
  final StreamController<NetworkStatus> _controller =
      StreamController<NetworkStatus>.broadcast();

  @override
  Stream<NetworkStatus> get statusStream => _controller.stream;

  @override
  Future<NetworkStatus> getCurrentStatus() async => status;

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}

class _FakeBackgroundSyncCoordinator implements BackgroundSyncCoordinator {
  int ensureStartedCallCount = 0;

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
  Future<void> ensureStarted() async {
    ensureStartedCallCount += 1;
  }

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> flush() async {}

  @override
  Future<void> triggerFromFcm({final String? hint}) async {}
}

Future<void> _pumpPage(
  final WidgetTester tester, {
  required final IotDemoState state,
}) async {
  final cubit = _TestIotDemoCubit()..setTestState(state);
  addTearDown(cubit.close);

  final SyncStatusCubit syncCubit = SyncStatusCubit(
    networkStatusService: _FakeNetworkStatusService(),
    coordinator: _FakeBackgroundSyncCoordinator(),
  );
  addTearDown(syncCubit.close);

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (final context) => MixTheme(
          data: buildAppMixThemeData(context),
          child: BlocProvider<SyncStatusCubit>.value(
            value: syncCubit,
            child: BlocProvider<IotDemoCubit>.value(
              value: cubit,
              child: const IotDemoPage(),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

Future<void> _pumpInteractivePage(
  final WidgetTester tester, {
  required final IotDemoRepository repository,
  _FakeBackgroundSyncCoordinator? coordinator,
}) async {
  final IotDemoCubit cubit = IotDemoCubit(repository: repository);
  addTearDown(cubit.close);

  final _FakeBackgroundSyncCoordinator syncCoordinator =
      coordinator ?? _FakeBackgroundSyncCoordinator();
  final SyncStatusCubit syncCubit = SyncStatusCubit(
    networkStatusService: _FakeNetworkStatusService(),
    coordinator: syncCoordinator,
  );
  addTearDown(syncCubit.close);

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (final context) => MixTheme(
          data: buildAppMixThemeData(context),
          child: BlocProvider<SyncStatusCubit>.value(
            value: syncCubit,
            child: BlocProvider<IotDemoCubit>.value(
              value: cubit,
              child: const IotDemoPage(),
            ),
          ),
        ),
      ),
    ),
  );

  await cubit.initialize();
  await tester.pump();
}

void main() {
  group('IotDemoPage', () {
    final l10n = AppLocalizationsEn();

    testWidgets('shows progress indicator in loading state', (
      final tester,
    ) async {
      await _pumpPage(tester, state: const IotDemoState.loading());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty message when device list is empty', (
      final tester,
    ) async {
      await _pumpPage(
        tester,
        state: IotDemoState.loaded([], selectedDeviceId: null),
      );

      expect(find.text(l10n.iotDemoDeviceListEmpty), findsOneWidget);
    });

    testWidgets('shows device list when loaded', (final tester) async {
      const devices = [
        IotDevice(
          id: 'light-1',
          name: 'Living Room Light',
          type: IotDeviceType.light,
        ),
      ];
      await _pumpPage(
        tester,
        state: IotDemoState.loaded(devices, selectedDeviceId: null),
      );

      expect(find.text(l10n.iotDemoPageTitle), findsOneWidget);
      expect(find.text('Living Room Light'), findsOneWidget);
    });

    testWidgets('filter buttons update the device list on first tap', (
      final tester,
    ) async {
      const List<IotDevice> devices = <IotDevice>[
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

      await _pumpInteractivePage(
        tester,
        repository: _StubIotDemoRepository(devices: devices),
      );

      expect(find.text('On Device'), findsOneWidget);
      expect(find.text('Off Device'), findsOneWidget);

      await tester.tap(find.text(l10n.iotDemoFilterOnOnly));
      await tester.pump();

      expect(find.text('On Device'), findsOneWidget);
      expect(find.text('Off Device'), findsNothing);
    });

    testWidgets('starts sync when page is shown', (final tester) async {
      final _FakeBackgroundSyncCoordinator coordinator =
          _FakeBackgroundSyncCoordinator();

      await _pumpInteractivePage(
        tester,
        repository: _StubIotDemoRepository(),
        coordinator: coordinator,
      );

      expect(coordinator.ensureStartedCallCount, 1);

      await tester.pump();

      expect(coordinator.ensureStartedCallCount, 1);
    });

    testWidgets('shows error and retry when in error state', (
      final tester,
    ) async {
      await _pumpPage(
        tester,
        state: IotDemoState.error('Something went wrong'),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets(
      'Set value dialog close does not use controller after dispose',
      (final tester) async {
        const devices = [
          IotDevice(
            id: 'thermostat-1',
            name: 'Thermostat',
            type: IotDeviceType.thermostat,
            connectionState: IotConnectionState.connected,
            value: 21,
          ),
        ];
        await _pumpPage(
          tester,
          state: IotDemoState.loaded(devices, selectedDeviceId: 'thermostat-1'),
        );
        await tester.pump();
        expect(find.text(l10n.iotDemoSetValue), findsOneWidget);
        await tester.tap(find.text(l10n.iotDemoSetValue));
        await tester.pumpAndSettle();
        expect(find.text(l10n.iotDemoSetValueHint), findsOneWidget);
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
        expect(find.text(l10n.iotDemoSetValueHint), findsNothing);
      },
    );
  });
}
