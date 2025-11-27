import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/constants.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/features/counter/presentation/pages/counter_page.dart';
import 'package:flutter_bloc_app/features/counter/presentation/widgets/counter_sync_banner.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_helpers.dart';

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
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> flush() async {}
}

void main() {
  setUpAll(() async {
    final Directory testDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(testDir.path);
    final HiveService hiveService = HiveService(
      keyManager: HiveKeyManager(storage: InMemorySecretStorage()),
    );
    await hiveService.initialize();
  });

  setUp(() async {
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
            child: const CounterPage(title: 'Counter'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final BuildContext bannerContext = tester.element(
      find.byType(CounterSyncBanner),
    );
    final AppLocalizations l10n = AppLocalizations.of(bannerContext);
    final MaterialLocalizations materialL10n = MaterialLocalizations.of(
      bannerContext,
    );
    final DateTime lastSynced = repository.snapshot.lastSyncedAt!;
    final String lastSyncedText =
        '${materialL10n.formatShortDate(lastSynced.toLocal())} · '
        '${materialL10n.formatTimeOfDay(TimeOfDay.fromDateTime(lastSynced.toLocal()))}';

    expect(find.text(l10n.counterLastSynced(lastSyncedText)), findsOneWidget);
    expect(
      find.text(l10n.counterChangeId(repository.snapshot.changeId!)),
      findsOneWidget,
    );
  });
}
