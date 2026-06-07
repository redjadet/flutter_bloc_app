import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/counter/counter.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_helpers.dart' show FakeTimerService;

class _FakeCounterRepository
    with CounterRepositoryNoPendingSync
    implements CounterRepository {
  _FakeCounterRepository({
    DateTime? lastSyncedAt,
    String? changeId,
    this.pendingCount = 0,
    this.queueEntries = const <CounterSyncQueueEntry>[],
  }) : _snapshot = CounterSnapshot(
         count: 1,
         lastSyncedAt: lastSyncedAt,
         changeId: changeId,
       );

  CounterSnapshot _snapshot;
  int pendingCount;
  List<CounterSyncQueueEntry> queueEntries;

  @override
  Future<CounterSnapshot> load() async => _snapshot;

  @override
  Future<void> save(final CounterSnapshot snapshot) async {
    _snapshot = snapshot;
  }

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

class MockNetworkStatusService extends Mock implements NetworkStatusService {}

class MockBackgroundSyncCoordinator extends Mock
    implements BackgroundSyncCoordinator {}

class TestSyncStatusCubit extends SyncStatusCubit {
  TestSyncStatusCubit({
    required super.networkStatusService,
    required super.coordinator,
  });

  void emitState(final SyncStatusState state) => emit(state);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CounterSyncBanner', () {
    late MockNetworkStatusService networkStatusService;
    late MockBackgroundSyncCoordinator coordinator;
    late TestSyncStatusCubit syncCubit;
    late _FakeCounterRepository counterRepository;
    late CounterCubit counterCubit;

    setUp(() async {
      await getIt.reset();
      networkStatusService = MockNetworkStatusService();
      coordinator = MockBackgroundSyncCoordinator();
      counterRepository = _FakeCounterRepository(
        lastSyncedAt: DateTime.utc(2024, 1, 1, 12, 0),
        changeId: 'abc123',
      );

      when(
        () => networkStatusService.statusStream,
      ).thenAnswer((_) => const Stream<NetworkStatus>.empty());
      when(
        () => networkStatusService.getCurrentStatus(),
      ).thenAnswer((_) async => NetworkStatus.online);
      when(
        () => coordinator.statusStream,
      ).thenAnswer((_) => const Stream<SyncStatus>.empty());
      when(() => coordinator.currentStatus).thenReturn(SyncStatus.idle);
      when(() => coordinator.history).thenReturn(const <SyncCycleSummary>[]);
      when(
        () => coordinator.summaryStream,
      ).thenAnswer((_) => const Stream<SyncCycleSummary>.empty());
      when(() => coordinator.latestSummary).thenReturn(null);
      when(() => coordinator.ensureStarted()).thenAnswer((_) async {});

      syncCubit = TestSyncStatusCubit(
        networkStatusService: networkStatusService,
        coordinator: coordinator,
      );
      counterCubit = CounterCubit(
        repository: counterRepository,
        startTicker: false,
        timerService: FakeTimerService(),
      );
    });

    tearDown(() async {
      await counterCubit.close();
      await syncCubit.close();
      await getIt.reset();
    });

    Widget buildBanner(final Widget child) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ResponsiveScope(
        child: MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<SyncStatusCubit>.value(value: syncCubit),
            BlocProvider<CounterCubit>.value(value: counterCubit),
          ],
          child: child,
        ),
      ),
    );

    testWidgets('shows offline banner with message', (tester) async {
      counterRepository.pendingCount = 0;
      await counterCubit.refreshPendingSyncCount();

      syncCubit.emitState(
        const SyncStatusState(
          networkStatus: NetworkStatus.offline,
          syncStatus: SyncStatus.idle,
        ),
      );

      await tester.pumpWidget(
        buildBanner(
          Builder(
            builder: (final context) =>
                CounterSyncBanner(l10n: AppLocalizations.of(context)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(CounterSyncBanner)),
      );
      expect(find.text(l10n.syncStatusOfflineTitle), findsOneWidget);
      expect(find.text(l10n.syncStatusOfflineMessage(0)), findsOneWidget);
    });

    testWidgets('shows syncing banner when operations pending', (tester) async {
      counterRepository.pendingCount = 1;
      await counterCubit.refreshPendingSyncCount();

      syncCubit.emitState(
        const SyncStatusState(
          networkStatus: NetworkStatus.online,
          syncStatus: SyncStatus.syncing,
        ),
      );

      await tester.pumpWidget(
        buildBanner(
          Builder(
            builder: (final context) =>
                CounterSyncBanner(l10n: AppLocalizations.of(context)),
          ),
        ),
      );
      await tester.pump();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(CounterSyncBanner)),
      );
      expect(find.text(l10n.syncStatusSyncingTitle), findsOneWidget);
      expect(find.text(l10n.syncStatusSyncingMessage(1)), findsOneWidget);
    });

    testWidgets('shows pending banner when queued items exist', (tester) async {
      counterRepository.pendingCount = 2;
      await counterCubit.refreshPendingSyncCount();

      syncCubit.emitState(
        const SyncStatusState(
          networkStatus: NetworkStatus.online,
          syncStatus: SyncStatus.idle,
        ),
      );

      await tester.pumpWidget(
        buildBanner(
          Builder(
            builder: (final context) =>
                CounterSyncBanner(l10n: AppLocalizations.of(context)),
          ),
        ),
      );
      await tester.pump();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(CounterSyncBanner)),
      );
      expect(find.text(l10n.syncStatusPendingTitle), findsOneWidget);
      expect(find.text(l10n.syncStatusPendingMessage(2)), findsOneWidget);
    });

    testWidgets('renders last synced metadata when provided', (tester) async {
      counterRepository.pendingCount = 0;
      await counterCubit.loadInitial();
      await tester.pumpAndSettle();

      syncCubit.emitState(
        const SyncStatusState(
          networkStatus: NetworkStatus.online,
          syncStatus: SyncStatus.idle,
        ),
      );

      await tester.pumpWidget(
        buildBanner(
          Builder(
            builder: (final context) =>
                CounterSyncBanner(l10n: AppLocalizations.of(context)),
          ),
        ),
      );
      await tester.pump();

      final BuildContext bannerContext = tester.element(
        find.byType(CounterSyncBanner),
      );
      final MaterialLocalizations locales = MaterialLocalizations.of(
        bannerContext,
      );
      final DateTime lastSynced = DateTime.utc(2024, 1, 1, 12, 0);
      final String expectedTimestamp =
          '${locales.formatShortDate(lastSynced.toLocal())} · ${locales.formatTimeOfDay(TimeOfDay.fromDateTime(lastSynced.toLocal()))}';
      final AppLocalizations l10n = AppLocalizations.of(bannerContext);

      expect(
        find.textContaining(
          l10n.counterLastSynced(expectedTimestamp).split(':').first,
        ),
        findsOneWidget,
      );
      expect(find.text(l10n.counterChangeId('abc123')), findsOneWidget);
    });
  });

  group('CounterSyncQueueInspectorButton', () {
    late _FakeCounterRepository counterRepository;
    late CounterCubit counterCubit;

    setUp(() {
      counterRepository = _FakeCounterRepository(
        pendingCount: 1,
        queueEntries: <CounterSyncQueueEntry>[
          const CounterSyncQueueEntry(
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
    });

    tearDown(() async {
      await counterCubit.close();
    });

    testWidgets('shows bottom sheet with operations when tapped', (
      tester,
    ) async {
      await counterCubit.refreshPendingSyncCount();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ResponsiveScope(
            child: BlocProvider<CounterCubit>.value(
              value: counterCubit,
              child: const Scaffold(body: CounterSyncQueueInspectorButton()),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.tap(find.text('View sync queue'));
      await tester.pumpAndSettle();

      expect(find.text('Pending Sync Operations'), findsOneWidget);
      expect(find.textContaining('Entity: counter'), findsOneWidget);
    });

    testWidgets('repository-backed mode refreshes when enqueue stream fires', (
      tester,
    ) async {
      final StreamController<void> enqueueController =
          StreamController<void>.broadcast();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ResponsiveScope(
            child: Scaffold(
              body: CounterSyncQueueInspectorButton(
                repository: counterRepository,
                onPendingSyncEnqueued: enqueueController.stream,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('View sync queue'), findsOneWidget);

      counterRepository.pendingCount = 0;
      enqueueController.add(null);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('View sync queue'), findsNothing);

      await enqueueController.close();
    });

    testWidgets('repository-backed mode works without CounterCubit', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ResponsiveScope(
            child: Scaffold(
              body: CounterSyncQueueInspectorButton(
                repository: counterRepository,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('View sync queue'), findsOneWidget);
    });
  });
}
