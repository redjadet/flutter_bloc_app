import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/widgets.dart' show Element;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_factories.dart';
import 'package:flutter_bloc_app/core/flavor.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_domain.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/features/counter/presentation/pages/counter_page.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_remote_data_source.dart';
import 'package:flutter_bloc_app/shared/services/app_image_cache_manager.dart';
import 'package:flutter_bloc_app/shared/services/app_memory_service.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/storage/hive_schema_migration.dart';
import 'package:flutter_bloc_app/shared/storage/shared_preferences_migration_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

const FirebaseOptions _fakeFirebaseOptions = FirebaseOptions(
  apiKey: 'fake-api-key',
  appId: 'fake-app-id',
  messagingSenderId: 'fake-sender-id',
  projectId: 'fake-project-id',
);

Future<void> ensureFirebaseInitializedForTests() async {
  final String platformType = FirebasePlatform.instance.runtimeType.toString();
  if (platformType.contains('MethodChannelFirebase')) {
    FirebasePlatform.instance = _MockFirebasePlatform();
  }

  if (Firebase.apps.isNotEmpty) {
    return;
  }

  await Firebase.initializeApp(options: _fakeFirebaseOptions);
}

class _MockFirebasePlatform extends FirebasePlatform {
  FirebaseOptions? _options;

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    _options = options;
    return _MockFirebaseApp(
      name ?? '[DEFAULT]',
      options ?? _fakeFirebaseOptions,
    );
  }

  @override
  List<FirebaseAppPlatform> get apps => [
    _MockFirebaseApp(
      '[DEFAULT]',
      _options ?? _fakeFirebaseOptions,
    ),
  ];

  @override
  FirebaseAppPlatform app([String name = '[DEFAULT]']) => _MockFirebaseApp(
    name,
    _options ?? _fakeFirebaseOptions,
  );
}

class _MockFirebaseApp extends FirebaseAppPlatform {
  _MockFirebaseApp(super.name, super.options);
}

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
}

class MockCounterRepository extends InMemoryRepository<CounterSnapshot>
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

Future<void> setupHiveForTesting() async {
  try {
    await Hive.initFlutter();
  } on Object catch (_) {
    // Repeated web init is fine; HiveService will verify storage when used.
  }
}

Future<void> setupTestDependencies([
  TestSetupOptions options = const TestSetupOptions(),
]) async {
  SharedPreferences.setMockInitialValues(
    options.initialSharedPreferencesValues ?? <String, Object>{},
  );
  if (options.useMockFirebasePlatform) {
    await ensureFirebaseInitializedForTests();
  }
  if (options.setFlavorToProd) {
    FlavorManager.current = Flavor.prod;
  }
  await getIt.reset();

  if (options.useMockFirebaseAuth) {
    getIt.registerSingleton<FirebaseAuth>(MockFirebaseAuth());
  }

  await configureDependencies();

  if (!options.useMockFirebaseAuth) {
    if (!getIt.isRegistered<FirebaseAuth>()) {
      getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
    }
  }

  await overrideNetworkAndSync();
  await overrideRemoteConfigRepositoryForWebSmoke();
  await overrideMemoryServicesForTests();
  if (options.overrideCounterRepository) {
    await overrideCounterRepository();
  }
  await getIt<SharedPreferencesMigrationService>().migrateIfNeeded();
}

Future<void> tearDownTestDependencies() async {
  await getIt.reset();
}

Future<void> overrideCounterRepository() async {
  if (getIt.isRegistered<CounterRepository>()) {
    await getIt.unregister<CounterRepository>();
  }
  getIt.registerSingleton<CounterRepository>(MockCounterRepository());
}

Future<void> overrideNetworkAndSync() async {
  if (getIt.isRegistered<BackgroundSyncCoordinator>()) {
    getIt.unregister<BackgroundSyncCoordinator>();
  }
  if (getIt.isRegistered<PendingSyncRepository>()) {
    getIt.unregister<PendingSyncRepository>();
  }
  if (getIt.isRegistered<NetworkStatusService>()) {
    getIt.unregister<NetworkStatusService>();
  }

  getIt
    ..registerLazySingleton<NetworkStatusService>(
      _FakeNetworkStatusService.new,
    )
    ..registerLazySingleton<BackgroundSyncCoordinator>(
      _FakeBackgroundSyncCoordinator.new,
    )
    ..registerLazySingleton<PendingSyncRepository>(
      _FakePendingSyncRepository.new,
    );
}

Future<void> overrideMemoryServicesForTests() async {
  if (getIt.isRegistered<AppMemoryService>()) {
    await getIt.unregister<AppMemoryService>();
  }
  if (getIt.isRegistered<AppImageCacheManager>()) {
    await getIt.unregister<AppImageCacheManager>();
  }

  getIt.registerLazySingleton<AppMemoryService>(
    () => AppMemoryService(onImageCacheTrim: (final level) async {}),
  );
}

/// Web integration smoke uses fake Firebase bootstrap options, so the real
/// Remote Config client would try to contact Firebase Installations with
/// invalid credentials. Keep the browser lane offline and deterministic.
Future<void> overrideRemoteConfigRepositoryForWebSmoke() async {
  if (getIt.isRegistered<RemoteConfigRemoteDataSource>()) {
    await getIt.unregister<RemoteConfigRemoteDataSource>();
  }
  getIt.registerLazySingleton<RemoteConfigRemoteDataSource>(
    FakeRemoteConfigRemoteDataSource.new,
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

class _FakePendingSyncRepository implements PendingSyncRepository {
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
  Future<void> safeDeleteKey(final Box<dynamic> box, final String key) async {}
}
