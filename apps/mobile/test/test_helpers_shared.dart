import 'dart:async';

import 'package:flutter/widgets.dart' show Element;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_domain.dart';
import 'package:flutter_bloc_app/features/counter/presentation/cubit/counter_cubit.dart';
import 'package:flutter_bloc_app/features/counter/presentation/pages/counter_page.dart';
import 'package:networking/networking.dart';
import 'package:storage/storage.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

export 'test_helpers_firebase.dart';

/// Generic in-memory repository used by tests to reduce bespoke mock classes.
class InMemoryRepository<T> {
  InMemoryRepository({
    required T initialValue,
    this.shouldThrowOnLoad = false,
    this.shouldThrowOnSave = false,
  }) : _value = initialValue;

  T _value;
  final bool shouldThrowOnLoad;
  final bool shouldThrowOnSave;
  StreamController<T>? _controller;

  Future<T> load() async {
    if (shouldThrowOnLoad) {
      throw Exception('Mock load error');
    }
    return _value;
  }

  Future<void> save(final T value) async {
    if (shouldThrowOnSave) {
      throw Exception('Mock save error');
    }
    _value = value;
    _controller?.add(_value);
  }

  Stream<T> watch() {
    _controller ??= StreamController<T>.broadcast(
      onListen: () => _controller?.add(_value),
    );
    return _controller!.stream;
  }

  Future<void> dispose() async {
    await _controller?.close();
    _controller = null;
  }
}

/// Counter repository mock backed by [InMemoryRepository] to share logic.
class MockCounterRepository extends InMemoryRepository<CounterSnapshot>
    with CounterRepositoryNoPendingSync
    implements CounterRepository {
  MockCounterRepository({
    CounterSnapshot? snapshot,
    super.shouldThrowOnLoad,
    super.shouldThrowOnSave,
  }) : super(
         initialValue:
             snapshot ?? const CounterSnapshot(userId: 'mock', count: 0),
       );
}

Future<void> waitForCounterCubitsToLoad(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final Stopwatch stopwatch = Stopwatch()..start();
  final Finder counterPageFinder = find.byType(CounterPage);
  bool sawCounterPage = false;

  while (stopwatch.elapsed < timeout) {
    final List<Element> elements = counterPageFinder.evaluate().toList();
    if (elements.isNotEmpty) {
      sawCounterPage = true;
      final bool allLoaded = elements.every((final element) {
        final CounterCubit cubit = element.read<CounterCubit>();
        return !cubit.state.status.isLoading;
      });
      if (allLoaded) {
        return;
      }
    }
    await tester.pump(const Duration(milliseconds: 50));
  }

  if (!sawCounterPage) {
    return;
  }

  // Some integration flows may never render the Counter page (e.g. they start
  // from a different initial route or land on an auth gate).
  throw StateError(
    'CounterCubit did not finish loading within ${timeout.inMilliseconds}ms',
  );
}

class TestSetupOptions {
  const TestSetupOptions({
    this.overrideCounterRepository = false,
    this.setFlavorToProd = false,
    this.initialSharedPreferencesValues,
    this.useMockFirebasePlatform = true,
    this.useMockFirebaseAuth = true,
  });

  final bool overrideCounterRepository;
  final bool setFlavorToProd;
  final Map<String, Object>? initialSharedPreferencesValues;
  final bool useMockFirebasePlatform;
  final bool useMockFirebaseAuth;
}

class FakeNetworkStatusService implements NetworkStatusService {
  @override
  Stream<NetworkStatus> get statusStream => const Stream<NetworkStatus>.empty();

  @override
  Future<NetworkStatus> getCurrentStatus() async => NetworkStatus.online;

  @override
  Future<void> dispose() async {}
}

class FakeBackgroundSyncCoordinator implements BackgroundSyncCoordinator {
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

class FakePendingSyncRepository implements PendingSyncRepository {
  final List<SyncOperation> _operations = <SyncOperation>[];

  @override
  String get boxName => 'fake-pending-sync-box';

  @override
  HiveBoxSchema? get schema => null;

  @override
  Stream<void> get onOperationEnqueued => const Stream<void>.empty();

  @override
  Future<SyncOperation> enqueue(final SyncOperation operation) async {
    _operations.add(operation);
    return operation;
  }

  @override
  Future<int> prune({
    int maxRetryCount = 10,
    Duration maxAge = const Duration(days: 30),
  }) async => 0;

  @override
  Future<List<SyncOperation>> getPendingOperations({
    DateTime? now,
    int? limit,
    String? supabaseUserIdFilter,
  }) async {
    Iterable<SyncOperation> out = _operations;
    if (supabaseUserIdFilter != null) {
      out = out.where((final op) {
        if (op.entityType != 'iot_demo') {
          return true;
        }
        final dynamic uid =
            op.payload[PendingSyncRepository.payloadKeySupabaseUserId];
        return uid == supabaseUserIdFilter;
      });
    }
    return out.toList(growable: false);
  }

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
  Future<void> dispose() async {}

  @override
  Future<Box<dynamic>> getBox() =>
      Future<Box<dynamic>>.error(UnimplementedError('Not used in fake'));

  @override
  Future<T> runWithBox<T>(
    final Future<T> Function(Box<dynamic> box) action,
  ) async => Future<T>.error(UnimplementedError('Not used in fake'));

  @override
  Future<void> safeDeleteKey(final Box<dynamic> box, final String key) async {}
}
