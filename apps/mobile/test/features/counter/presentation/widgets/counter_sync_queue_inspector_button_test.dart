import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/app/sync/sync_banner_helpers.dart';
import 'package:flutter_bloc_app/features/counter/counter.dart';
import 'package:flutter_bloc_app/l10n/app_localization_delegates.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:networking/networking.dart';

import '../../../../test_helpers.dart' show FakeTimerService;

class _FakeNetworkStatusService implements NetworkStatusService {
  @override
  Stream<NetworkStatus> get statusStream => const Stream<NetworkStatus>.empty();

  @override
  Future<NetworkStatus> getCurrentStatus() async => NetworkStatus.online;

  @override
  Future<void> dispose() async {}
}

class _FakeBackgroundSyncCoordinator implements BackgroundSyncCoordinator {
  SyncStatus current = SyncStatus.idle;

  int ensureStartedCalls = 0;

  @override
  SyncStatus get currentStatus => current;

  @override
  List<SyncCycleSummary> get history => const <SyncCycleSummary>[];

  @override
  SyncCycleSummary? get latestSummary => null;

  @override
  Stream<SyncCycleSummary> get summaryStream =>
      const Stream<SyncCycleSummary>.empty();

  @override
  Stream<SyncStatus> get statusStream => const Stream<SyncStatus>.empty();

  @override
  Future<void> ensureStarted() async {
    ensureStartedCalls += 1;
  }

  @override
  Future<void> flush() async {}

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> triggerFromFcm({String? hint}) async {}

  @override
  Future<void> quiesceForSessionCleanup() async {}

  @override
  Future<void> resumeAfterSessionCleanup() async {}

  @override
  Future<void> dispose() => Future<void>.value();
}

class _FakeCounterRepository
    with CounterRepositoryNoPendingSync
    implements CounterRepository {
  _FakeCounterRepository({
    this.pendingCount = 1,
    this.queueEntries = const <CounterSyncQueueEntry>[],
  }) : _snapshot = const CounterSnapshot(
         count: 1,
         lastSyncedAt: null,
         changeId: null,
       );

  final CounterSnapshot _snapshot;
  final int pendingCount;
  final List<CounterSyncQueueEntry> queueEntries;

  @override
  Future<CounterSnapshot> load() async => _snapshot;

  @override
  Future<void> save(CounterSnapshot snapshot) async {}

  @override
  Stream<CounterSnapshot> watch() async* {
    yield _snapshot;
  }

  @override
  Future<int> pendingSyncOperationCount({DateTime? now}) async => pendingCount;

  @override
  Future<List<CounterSyncQueueEntry>> pendingSyncQueueEntries({
    DateTime? now,
  }) async => queueEntries;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CounterSyncQueueInspectorButton', () {
    late _FakeBackgroundSyncCoordinator coordinator;
    late SyncStatusCubit syncCubit;
    late _FakeCounterRepository counterRepository;
    late CounterCubit counterCubit;

    setUp(() async {
      await getIt.reset();

      coordinator = _FakeBackgroundSyncCoordinator();
      syncCubit = SyncStatusCubit(
        networkStatusService: _FakeNetworkStatusService(),
        coordinator: coordinator,
      );

      counterRepository = _FakeCounterRepository(
        pendingCount: 1,
        queueEntries: const <CounterSyncQueueEntry>[
          CounterSyncQueueEntry(
            id: 'op-1',
            entityType: 'counter',
            retryCount: 0,
          ),
        ],
      );

      counterCubit = CounterCubit(
        repository: counterRepository,
        startTicker: false,
        timerService: FakeTimerService(),
      );
      await counterCubit.refreshPendingSyncCount();
    });

    tearDown(() async {
      await counterCubit.close();
      await syncCubit.close();
      await getIt.reset();
    });

    Widget buildWidget() => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: appLocalizationDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ResponsiveScope(
        child: MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<SyncStatusCubit>.value(value: syncCubit),
            BlocProvider<CounterCubit>.value(value: counterCubit),
          ],
          child: const Scaffold(body: CounterSyncQueueInspectorButton()),
        ),
      ),
    );

    testWidgets(
      'starts sync once from didChangeDependencies when UI flag enabled',
      (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pump();

        await tester.pumpWidget(buildWidget());
        await tester.pump();

        final int expectedCalls = kShowPendingSyncQueueUi ? 1 : 0;
        expect(coordinator.ensureStartedCalls, expectedCalls);
      },
    );
  });
}
