import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/counter/counter.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _FakeCounterRepository implements CounterRepository {
  _FakeCounterRepository({DateTime? lastSyncedAt, String? changeId})
    : _snapshot = CounterSnapshot(
        count: 1,
        lastSyncedAt: lastSyncedAt,
        changeId: changeId,
      );

  CounterSnapshot _snapshot;

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
}

class MockNetworkStatusService extends Mock implements NetworkStatusService {}

class MockBackgroundSyncCoordinator extends Mock
    implements BackgroundSyncCoordinator {}

class MockPendingSyncRepository extends Mock implements PendingSyncRepository {}

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
    late MockPendingSyncRepository pendingRepository;
    late TestSyncStatusCubit cubit;
    late _FakeCounterRepository counterRepository;

    setUp(() async {
      await getIt.reset();
      networkStatusService = MockNetworkStatusService();
      coordinator = MockBackgroundSyncCoordinator();
      pendingRepository = MockPendingSyncRepository();
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
      getIt.registerSingleton<PendingSyncRepository>(pendingRepository);
      getIt.registerSingleton<CounterRepository>(counterRepository);

      cubit = TestSyncStatusCubit(
        networkStatusService: networkStatusService,
        coordinator: coordinator,
      );
    });

    tearDown(() async {
      await cubit.close();
      await getIt.reset();
    });

    Widget buildBanner(final Widget child) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ResponsiveScope(child: child),
    );

    testWidgets('shows offline banner with message', (tester) async {
      when(
        () => pendingRepository.getPendingOperations(now: any(named: 'now')),
      ).thenAnswer((final _) async => <SyncOperation>[]);

      cubit.emitState(
        const SyncStatusState(
          networkStatus: NetworkStatus.offline,
          syncStatus: SyncStatus.idle,
        ),
      );

      await tester.pumpWidget(
        buildBanner(
          BlocProvider<SyncStatusCubit>.value(
            value: cubit,
            child: Builder(
              builder: (final context) =>
                  CounterSyncBanner(l10n: AppLocalizations.of(context)),
            ),
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
      when(
        () => pendingRepository.getPendingOperations(now: any(named: 'now')),
      ).thenAnswer(
        (final _) async => <SyncOperation>[
          SyncOperation.create(
            entityType: 'counter',
            payload: const CounterSnapshot(count: 1).toJson(),
            idempotencyKey: 'key',
          ),
        ],
      );

      cubit.emitState(
        const SyncStatusState(
          networkStatus: NetworkStatus.online,
          syncStatus: SyncStatus.syncing,
        ),
      );

      await tester.pumpWidget(
        buildBanner(
          BlocProvider<SyncStatusCubit>.value(
            value: cubit,
            child: Builder(
              builder: (final context) =>
                  CounterSyncBanner(l10n: AppLocalizations.of(context)),
            ),
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
      when(
        () => pendingRepository.getPendingOperations(now: any(named: 'now')),
      ).thenAnswer(
        (final _) async => <SyncOperation>[
          SyncOperation.create(
            entityType: 'counter',
            payload: const CounterSnapshot(count: 2).toJson(),
            idempotencyKey: 'key2',
          ),
          SyncOperation.create(
            entityType: 'counter',
            payload: const CounterSnapshot(count: 3).toJson(),
            idempotencyKey: 'key3',
          ),
        ],
      );

      cubit.emitState(
        const SyncStatusState(
          networkStatus: NetworkStatus.online,
          syncStatus: SyncStatus.idle,
        ),
      );

      await tester.pumpWidget(
        buildBanner(
          BlocProvider<SyncStatusCubit>.value(
            value: cubit,
            child: Builder(
              builder: (final context) =>
                  CounterSyncBanner(l10n: AppLocalizations.of(context)),
            ),
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
      when(
        () => pendingRepository.getPendingOperations(now: any(named: 'now')),
      ).thenAnswer((final _) async => <SyncOperation>[]);

      cubit.emitState(
        const SyncStatusState(
          networkStatus: NetworkStatus.online,
          syncStatus: SyncStatus.idle,
        ),
      );

      await tester.pumpWidget(
        buildBanner(
          BlocProvider<SyncStatusCubit>.value(
            value: cubit,
            child: Builder(
              builder: (final context) =>
                  CounterSyncBanner(l10n: AppLocalizations.of(context)),
            ),
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
    late MockPendingSyncRepository pendingRepository;

    setUp(() async {
      pendingRepository = MockPendingSyncRepository();
      await getIt.reset();
      getIt.registerSingleton<PendingSyncRepository>(pendingRepository);
    });

    tearDown(() async {
      await getIt.reset();
    });

    testWidgets('shows bottom sheet with operations when tapped', (
      tester,
    ) async {
      final List<SyncOperation> operations = <SyncOperation>[
        SyncOperation.create(
          entityType: 'counter',
          payload: const CounterSnapshot(count: 1).toJson(),
          idempotencyKey: 'a',
        ),
      ];
      when(
        () => pendingRepository.getPendingOperations(now: any(named: 'now')),
      ).thenAnswer((final _) async => operations);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ResponsiveScope(
            child: Scaffold(body: const CounterSyncQueueInspectorButton()),
          ),
        ),
      );

      await tester.tap(find.text('View sync queue'));
      await tester.pumpAndSettle();

      expect(find.text('Pending Sync Operations'), findsOneWidget);
      expect(find.textContaining('Entity: counter'), findsOneWidget);
    });
  });
}
