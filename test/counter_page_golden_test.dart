import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_domain.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/features/counter/presentation/pages/counter_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/core/flavor.dart';
import 'package:flutter_bloc_app/shared/storage/shared_preferences_migration_service.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';

import 'test_helpers.dart';

final DateTime _goldenTimestamp = DateTime.utc(2024, 1, 1, 12);

void main() {
  group('CounterPage Golden', () {
    setUpAll(() async {
      await loadAppFonts();
      // Initialize Hive for testing
      final Directory testDir = Directory.systemTemp.createTempSync(
        'hive_test_',
      );
      Hive.init(testDir.path);
    });

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      // Set flavor to non-dev to avoid skeleton delay in tests
      FlavorManager.current = Flavor.prod;
      await getIt.reset(dispose: true);
      await configureDependencies();
      await _overrideNetworkAndSync();
      overrideCounterRepository();
      // Run migration to avoid delays during widget test
      await getIt<SharedPreferencesMigrationService>().migrateIfNeeded();
    });

    tearDown(() async {
      await getIt.reset(dispose: true);
    });

    testGoldens('renders correctly on common devices', (tester) async {
      final cubit = CounterCubit(
        repository: MockCounterRepository(),
        timerService: FakeTimerService(),
        now: _fixedNow,
      )..loadInitial();
      addTearDown(cubit.close);
      await tester.pumpWidget(
        _buildCounterPageApp(cubit: cubit, theme: ThemeData.light()),
      );
      await tester.pump();
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      await waitForCounterCubitsToLoad(tester);
      expect(find.byType(CounterPage), findsOneWidget);
      expect(find.text('0'), findsWidgets);
      await multiScreenGolden(
        tester,
        'counter_page_initial',
        devices: const [
          Device.phone,
          Device.tabletPortrait,
          Device.tabletLandscape,
        ],
      );
    });

    testGoldens('renders loading state without settling', (tester) async {
      await tester.pumpWidgetBuilder(const MyApp(requireAuth: false));
      // Wait a bit for initial render but don't wait for full settle
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await multiScreenGolden(
        tester,
        'counter_page_loading',
        devices: const [Device.phone, Device.tabletPortrait],
      );
    });

    testGoldens('counter components in TR locale', (tester) async {
      final Widget demo = _CounterComponentsDemo();
      await tester.pumpWidgetBuilder(
        demo,
        wrapper: materialAppWrapper(
          localizations: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          theme: ThemeData.light(),
          localeOverrides: const [Locale('tr')],
        ),
      );
      await multiScreenGolden(
        tester,
        'counter_components_tr',
        devices: const [Device.phone],
      );
    });

    testGoldens('counter page active countdown', (tester) async {
      final fakeTimer = FakeTimerService();
      final cubit = CounterCubit(
        repository: MockCounterRepository(
          snapshot: const CounterSnapshot(count: 2),
        ),
        timerService: fakeTimer,
        now: _fixedNow,
      );
      cubit.loadInitial();
      await tester.pumpWidget(
        _buildCounterPageApp(cubit: cubit, theme: ThemeData.light()),
      );
      fakeTimer.tick(2);
      await tester.pump();
      await waitForCounterCubitsToLoad(tester);
      await multiScreenGolden(
        tester,
        'counter_page_active',
        devices: const [Device.phone, Device.tabletPortrait],
      );
      addTearDown(cubit.close);
    });

    testGoldens('counter page paused (count = 0)', (tester) async {
      final cubit = CounterCubit(
        repository: MockCounterRepository(
          snapshot: const CounterSnapshot(count: 0),
        ),
        timerService: FakeTimerService(),
        startTicker: true,
        now: _fixedNow,
      );
      cubit.loadInitial();
      await tester.pumpWidget(
        _buildCounterPageApp(cubit: cubit, theme: ThemeData.light()),
      );
      await tester.pump();
      await waitForCounterCubitsToLoad(tester);
      await multiScreenGolden(
        tester,
        'counter_page_paused',
        devices: const [Device.phone, Device.tabletPortrait],
      );
      addTearDown(cubit.close);
    });

    testGoldens('counter page active countdown - dark', (tester) async {
      final fakeTimer = FakeTimerService();
      final cubit = CounterCubit(
        repository: MockCounterRepository(
          snapshot: const CounterSnapshot(count: 3),
        ),
        timerService: fakeTimer,
        now: _fixedNow,
      );
      cubit.loadInitial();
      await tester.pumpWidget(
        _buildCounterPageApp(cubit: cubit, theme: ThemeData.dark()),
      );
      fakeTimer.tick(2);
      await tester.pump();
      await waitForCounterCubitsToLoad(tester);
      await multiScreenGolden(
        tester,
        'counter_page_active_dark',
        devices: const [Device.phone, Device.tabletPortrait],
      );
      addTearDown(cubit.close);
    });

    testGoldens('counter page paused (count = 0) - dark', (tester) async {
      final cubit = CounterCubit(
        repository: MockCounterRepository(
          snapshot: const CounterSnapshot(count: 0),
        ),
        timerService: FakeTimerService(),
        startTicker: true,
        now: _fixedNow,
      );
      cubit.loadInitial();
      await tester.pumpWidget(
        _buildCounterPageApp(cubit: cubit, theme: ThemeData.dark()),
      );
      await tester.pump();
      await waitForCounterCubitsToLoad(tester);
      await multiScreenGolden(
        tester,
        'counter_page_paused_dark',
        devices: const [Device.phone, Device.tabletPortrait],
      );
      addTearDown(cubit.close);
    });
  });
}

DateTime _fixedNow() => _goldenTimestamp;

Widget _buildCounterPageApp({required CounterCubit cubit, ThemeData? theme}) =>
    ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) => MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<CounterCubit>.value(value: cubit),
          BlocProvider<SyncStatusCubit>(
            create: (_) => SyncStatusCubit(
              networkStatusService: _FakeNetworkStatusService(),
              coordinator: _FakeBackgroundSyncCoordinator(),
            ),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: theme ?? ThemeData.light(),
          home: const CounterPage(title: 'Counter'),
        ),
      ),
    );

Future<void> _overrideNetworkAndSync() async {
  if (getIt.isRegistered<BackgroundSyncCoordinator>()) {
    getIt.unregister<BackgroundSyncCoordinator>();
  }
  if (getIt.isRegistered<PendingSyncRepository>()) {
    getIt.unregister<PendingSyncRepository>();
  }
  if (getIt.isRegistered<NetworkStatusService>()) {
    getIt.unregister<NetworkStatusService>();
  }

  getIt.registerLazySingleton<NetworkStatusService>(
    _FakeNetworkStatusService.new,
  );
  getIt.registerLazySingleton<BackgroundSyncCoordinator>(
    _FakeBackgroundSyncCoordinator.new,
  );
  getIt.registerLazySingleton<PendingSyncRepository>(
    _FakePendingSyncRepository.new,
  );
}

class _CounterComponentsDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer, size: 18, color: colors.primary),
                  const SizedBox(width: 6),
                  Text(
                    l10n.autoLabel,
                    style: textTheme.labelMedium?.copyWith(
                      color: colors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: 0.6,
                minHeight: 8,
                backgroundColor: colors.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FakeNetworkStatusService implements NetworkStatusService {
  @override
  Stream<NetworkStatus> get statusStream => const Stream<NetworkStatus>.empty();

  @override
  Future<NetworkStatus> getCurrentStatus() async => NetworkStatus.online;

  @override
  Future<void> dispose() async {}
}

class _FakePendingSyncRepository implements PendingSyncRepository {
  final List<SyncOperation> _operations = <SyncOperation>[];

  @override
  String get boxName => 'fake-pending-sync-box';

  @override
  Future<SyncOperation> enqueue(final SyncOperation operation) async {
    _operations
      ..removeWhere((final SyncOperation op) => op.id == operation.id)
      ..add(operation);
    return operation;
  }

  @override
  Future<List<SyncOperation>> getPendingOperations({
    DateTime? now,
    int? limit,
  }) async {
    final DateTime threshold = (now ?? DateTime.now()).toUtc();
    final Iterable<SyncOperation> ready = _operations.where(
      (final SyncOperation op) =>
          op.nextRetryAt == null || !op.nextRetryAt!.isAfter(threshold),
    );
    final List<SyncOperation> pending = ready.toList(growable: false);
    if (limit == null) return pending;
    return pending.take(limit).toList(growable: false);
  }

  @override
  Future<void> markCompleted(final String operationId) async {
    _operations.removeWhere((final SyncOperation op) => op.id == operationId);
  }

  @override
  Future<void> markFailed({
    required final String operationId,
    required final DateTime nextRetryAt,
    final int? retryCount,
  }) async {
    final int index = _operations.indexWhere(
      (final SyncOperation op) => op.id == operationId,
    );
    if (index == -1) return;
    final SyncOperation current = _operations[index];
    _operations[index] = current.copyWith(
      nextRetryAt: nextRetryAt,
      retryCount: retryCount ?? (current.retryCount + 1),
    );
  }

  @override
  Future<void> clear() async {
    _operations.clear();
  }

  @override
  Future<int> prune({
    int maxRetryCount = 10,
    Duration maxAge = const Duration(days: 30),
  }) async => 0;

  @override
  Future<Box<dynamic>> getBox() =>
      Future<Box<dynamic>>.error(UnimplementedError('Not used in fake'));

  @override
  Future<void> safeDeleteKey(final Box<dynamic> box, final String key) async {}

  @override
  bool operator ==(final Object other) =>
      identical(this, other) || other.runtimeType == runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
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
