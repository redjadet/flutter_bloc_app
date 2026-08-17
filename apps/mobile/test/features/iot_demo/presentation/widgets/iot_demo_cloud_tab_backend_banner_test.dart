import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/app/theme/theme.dart';
import 'package:flutter_bloc_app/app/widgets/backend_disabled_banner.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_device_filter.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device_command.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/cubit/iot_demo_cubit.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/cubit/iot_demo_state.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/widgets/iot_demo_cloud_tab.dart';
import 'package:flutter_bloc_app/l10n/app_localization_delegates.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:networking/networking.dart';

void main() {
  testWidgets(
    'IotDemoCloudTab shows backend banner when showBackendDisabledBanner is true',
    (tester) async {
      await _pumpCloudTab(tester, showBackendDisabledBanner: true);

      expect(find.byType(BackendDisabledBanner), findsOneWidget);
      expect(find.text('Backend disabled'), findsOneWidget);
    },
  );

  testWidgets(
    'IotDemoCloudTab hides backend banner when showBackendDisabledBanner is false',
    (tester) async {
      await _pumpCloudTab(tester, showBackendDisabledBanner: false);

      expect(find.text('Backend disabled'), findsNothing);
    },
  );
}

Future<void> _pumpCloudTab(
  WidgetTester tester, {
  required bool showBackendDisabledBanner,
}) async {
  final IotDemoCubit cubit = IotDemoCubit(repository: _StubIotDemoRepository())
    ..emit(const IotDemoState.loaded(<IotDevice>[], selectedDeviceId: null));
  addTearDown(cubit.close);

  final SyncStatusCubit syncCubit = SyncStatusCubit(
    networkStatusService: _FakeNetworkStatusService(),
    coordinator: _FakeBackgroundSyncCoordinator(),
  );
  addTearDown(syncCubit.close);

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: appLocalizationDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => buildAppMixScope(
          context,
          child: BlocProvider<SyncStatusCubit>.value(
            value: syncCubit,
            child: BlocProvider<IotDemoCubit>.value(
              value: cubit,
              child: IotDemoCloudTab(
                showBackendDisabledBanner: showBackendDisabledBanner,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

class _StubIotDemoRepository implements IotDemoRepository {
  @override
  Stream<List<IotDevice>> watchDevices([
    IotDemoDeviceFilter filter = IotDemoDeviceFilter.all,
  ]) => Stream<List<IotDevice>>.value(const <IotDevice>[]);

  @override
  Future<void> addDevice(IotDevice device) async {}

  @override
  Future<void> connect(String deviceId) async {}

  @override
  Future<void> disconnect(String deviceId) async {}

  @override
  Future<void> sendCommand(String deviceId, IotDeviceCommand command) async {}
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
  Future<void> triggerFromFcm({String? hint}) async {}
  @override
  Future<void> quiesceForSessionCleanup() async {}

  @override
  Future<void> resumeAfterSessionCleanup() async {}
}
