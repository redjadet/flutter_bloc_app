// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/flavor.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/storage/shared_preferences_migration_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    // Initialize Hive for testing
    final Directory testDir = Directory.systemTemp.createTempSync('hive_test_');
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

  testWidgets('Counter increments and decrements using Bloc', (
    WidgetTester tester,
  ) async {
    await initializeDateFormatting('en');
    await tester.pumpWidget(const MyApp(requireAuth: false));
    // Wait for initial build
    await tester.pump();
    await waitForCounterCubitsToLoad(tester);

    final Finder incrementFinder = find.widgetWithIcon(
      FloatingActionButton,
      Icons.add,
    );

    // Wait for widget to appear and loading to complete
    // In dev mode, there's a skeleton delay (1s) + Hive load time
    final Duration maxWait = const Duration(seconds: 4);
    const Duration step = Duration(milliseconds: 100);
    Duration waited = Duration.zero;

    // Wait for FAB to appear
    while (!tester.any(incrementFinder) && waited < maxWait) {
      await tester.pump(step);
      waited += step;
    }
    expect(incrementFinder, findsOneWidget);

    // Wait for loading to complete (FAB enabled)
    // Reset wait time for the second loop
    waited = Duration.zero;
    FloatingActionButton? incrementFab;
    while (waited < maxWait) {
      await tester.pump(step);
      waited += step;
      try {
        incrementFab = tester.widget<FloatingActionButton>(incrementFinder);
        if (incrementFab.onPressed != null) {
          break;
        }
      } catch (_) {
        // Widget might not be ready yet, continue waiting
      }
    }
    expect(
      incrementFab?.onPressed,
      isNotNull,
      reason: 'FAB should be enabled after repository loads',
    );

    // There may be multiple '0' texts in UI; rely on semantics by tapping FABs
    expect(find.text('0'), findsWidgets);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('1'), findsWidgets);

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();

    expect(find.text('0'), findsWidgets);
  });
}

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
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> flush() async {}
}

class _FakePendingSyncRepository implements PendingSyncRepository {
  final List<SyncOperation> _operations = <SyncOperation>[];

  @override
  String get boxName => 'fake-pending-sync-box';

  @override
  Future<SyncOperation> enqueue(final SyncOperation operation) async {
    _operations.add(operation);
    return operation;
  }

  @override
  Future<List<SyncOperation>> getPendingOperations({
    DateTime? now,
    int? limit,
  }) async => _operations.toList(growable: false);

  @override
  Future<void> markCompleted(final String operationId) async {}

  @override
  Future<void> markFailed({
    required final String operationId,
    required final DateTime nextRetryAt,
    final int? retryCount,
  }) async {}

  @override
  Future<void> clear() async => _operations.clear();

  @override
  Future<Box<dynamic>> getBox() =>
      Future<Box<dynamic>>.error(UnimplementedError('Not used in fake'));

  @override
  Future<void> safeDeleteKey(final Box<dynamic> box, final String key) async {}

  @override
  Future<int> prune({
    int maxRetryCount = 10,
    Duration maxAge = const Duration(days: 30),
  }) async => 0;
}
