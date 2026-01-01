import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/constants.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/flavor.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/features/counter/presentation/pages/counter_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/platform/biometric_authenticator.dart';
import 'package:flutter_bloc_app/shared/services/error_notification_service.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_helpers.dart' as test_helpers;
import '../../../../test_helpers.dart' show FakeTimerService;

class _MetadataCounterRepository implements CounterRepository {
  _MetadataCounterRepository()
    : snapshot = CounterSnapshot(
        userId: 'tester',
        count: 7,
        lastSyncedAt: DateTime.utc(2024, 1, 2, 15, 30),
        changeId: 'sync-123',
        synchronized: true,
      );

  CounterSnapshot snapshot;

  @override
  Future<CounterSnapshot> load() async => snapshot;

  @override
  Future<void> save(CounterSnapshot snapshot) async {
    this.snapshot = snapshot;
  }

  @override
  Stream<CounterSnapshot> watch() async* {
    yield snapshot;
  }
}

class _MockPendingSyncRepository extends Mock
    implements PendingSyncRepository {}

class _FakeNetworkStatusService implements NetworkStatusService {
  final Stream<NetworkStatus> _updates = Stream<NetworkStatus>.value(
    NetworkStatus.online,
  );

  @override
  Stream<NetworkStatus> get statusStream => _updates;

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
}

class _FakeBiometricAuthenticator implements BiometricAuthenticator {
  @override
  Future<bool> authenticate({String? localizedReason}) async => true;
}

class _FakeErrorNotificationService implements ErrorNotificationService {
  @override
  Future<void> showAlertDialog(
    BuildContext context,
    String title,
    String message,
  ) async {}

  @override
  Future<void> showSnackBar(BuildContext context, String message) async {}
}

void main() {
  setUpAll(() async {
    await test_helpers.setupHiveForTesting();
    // Initialize Hive service for testing
    await test_helpers.createHiveService();
  });

  setUp(() async {
    FlavorManager.current = Flavor.dev;
    getIt.pushNewScope();
    await configureDependencies();
  });

  tearDown(() {
    getIt.popScope();
  });

  testWidgets('CounterPage surfaces last synced metadata', (
    WidgetTester tester,
  ) async {
    final _MetadataCounterRepository repository = _MetadataCounterRepository();
    final _MockPendingSyncRepository pendingRepository =
        _MockPendingSyncRepository();
    final _FakeBiometricAuthenticator authenticator =
        _FakeBiometricAuthenticator();
    final _FakeErrorNotificationService errorNotifications =
        _FakeErrorNotificationService();

    if (getIt.isRegistered<CounterRepository>()) {
      getIt.unregister<CounterRepository>();
    }
    if (getIt.isRegistered<PendingSyncRepository>()) {
      getIt.unregister<PendingSyncRepository>();
    }
    getIt.registerSingleton<CounterRepository>(repository);
    getIt.registerSingleton<PendingSyncRepository>(pendingRepository);
    when(
      () => pendingRepository.getPendingOperations(now: any(named: 'now')),
    ).thenAnswer((_) async => <SyncOperation>[]);

    final CounterCubit counterCubit = CounterCubit(
      repository: repository,
      timerService: FakeTimerService(),
      startTicker: false,
    )..loadInitial();
    final SyncStatusCubit syncCubit = SyncStatusCubit(
      networkStatusService: _FakeNetworkStatusService(),
      coordinator: _FakeBackgroundSyncCoordinator(),
    );

    addTearDown(counterCubit.close);
    addTearDown(syncCubit.close);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: AppConstants.designSize,
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MultiBlocProvider(
            providers: <BlocProvider<dynamic>>[
              BlocProvider<CounterCubit>.value(value: counterCubit),
              BlocProvider<SyncStatusCubit>.value(value: syncCubit),
            ],
            child: CounterPage(
              title: 'Counter',
              errorNotificationService: errorNotifications,
              biometricAuthenticator: authenticator,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify that sync metadata is available in CounterCubit state
    final CounterState state = counterCubit.state;
    expect(state.lastSyncedAt, equals(repository.snapshot.lastSyncedAt));
    expect(state.changeId, equals(repository.snapshot.changeId));

    // Verify the metadata values are not null
    expect(state.lastSyncedAt, isNotNull);
    expect(state.changeId, isNotNull);
    expect(state.lastSyncedAt, equals(DateTime.utc(2024, 1, 2, 15, 30)));
    expect(state.changeId, equals('sync-123'));
  });
}
