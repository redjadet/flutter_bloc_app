import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/flavor.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_api_client.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_payload_builder.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_response_parser.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_domain.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/features/counter/presentation/pages/counter_page.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_preference.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_repository.dart';
import 'package:flutter_bloc_app/features/settings/presentation/cubits/theme_cubit.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/storage/shared_preferences_migration_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

/// Test helper for wrapping widgets with necessary providers
Widget wrapWithProviders({
  required Widget child,
  CounterRepository? repository,
  ThemeMode initialThemeMode = ThemeMode.system,
}) => ScreenUtilInit(
  designSize: const Size(390, 844),
  minTextAdapt: true,
  splitScreenMode: true,
  builder: (context, _) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (ctx) =>
            CounterCubit(repository: repository ?? MockCounterRepository())
              ..loadInitial(),
      ),
      BlocProvider(
        create: (_) =>
            ThemeCubit(repository: _FakeThemeRepository(initialThemeMode))
              ..emit(initialThemeMode),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: const [AppLocalizations.delegate],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  ),
);

/// Test helper for setting up SharedPreferences mock
void setupSharedPreferencesMock({Map<String, Object>? initialValues}) {
  SharedPreferences.setMockInitialValues(initialValues ?? <String, Object>{});
}

/// Overrides the shared Hugging Face HTTP client so tests can inject mocks.
///
/// This mutates the root GetIt scope and should be paired with manual cleanup
/// (e.g. rerunning `configureDependencies`). Prefer using
/// [runWithHuggingFaceHttpClientOverride] to keep overrides scoped.
@Deprecated('Prefer runWithHuggingFaceHttpClientOverride for scoped overrides.')
void overrideHuggingFaceHttpClient(
  http.Client client, {
  required String apiKey,
  required String model,
  required bool useChatCompletions,
}) {
  if (getIt.isRegistered<ChatRepository>()) {
    getIt.unregister<ChatRepository>();
  }
  if (getIt.isRegistered<HuggingFaceApiClient>()) {
    getIt.unregister<HuggingFaceApiClient>();
  }
  if (getIt.isRegistered<http.Client>()) {
    getIt.unregister<http.Client>();
  }

  _registerHuggingFaceDependencies(
    client,
    apiKey: apiKey,
    model: model,
    useChatCompletions: useChatCompletions,
  );
}

/// Runs [action] within a GetIt scope that overrides Hugging Face dependencies.
/// The provided [client] is automatically disposed if [closeClient] is true.
Future<T> runWithHuggingFaceHttpClientOverride<T>({
  required http.Client client,
  required String apiKey,
  required String model,
  required bool useChatCompletions,
  bool closeClient = true,
  required Future<T> Function() action,
}) async {
  getIt.pushNewScope(scopeName: 'huggingface-test-override');
  _registerHuggingFaceDependencies(
    client,
    apiKey: apiKey,
    model: model,
    useChatCompletions: useChatCompletions,
  );
  try {
    return await action();
  } finally {
    if (closeClient) {
      client.close();
    }
    await getIt.popScope();
  }
}

void _registerHuggingFaceDependencies(
  http.Client client, {
  required String apiKey,
  required String model,
  required bool useChatCompletions,
}) {
  getIt.registerSingleton<http.Client>(client);
  getIt.registerLazySingleton<HuggingFaceApiClient>(
    () =>
        HuggingFaceApiClient(httpClient: getIt<http.Client>(), apiKey: apiKey),
  );
  getIt.registerLazySingleton<HuggingFacePayloadBuilder>(
    () => const HuggingFacePayloadBuilder(),
  );
  getIt.registerLazySingleton<HuggingFaceResponseParser>(
    () => const HuggingFaceResponseParser(
      fallbackMessage: HuggingfaceChatRepository.fallbackMessage,
    ),
  );
  getIt.registerLazySingleton<ChatRepository>(
    () => HuggingfaceChatRepository(
      apiClient: getIt<HuggingFaceApiClient>(),
      payloadBuilder: getIt<HuggingFacePayloadBuilder>(),
      responseParser: getIt<HuggingFaceResponseParser>(),
      model: model,
      useChatCompletions: useChatCompletions,
    ),
  );
}

class _FakeThemeRepository implements ThemeRepository {
  _FakeThemeRepository(this.initial) : _stored = _toPreference(initial);

  final ThemeMode initial;
  ThemePreference? _stored;

  ThemePreference? saved;

  @override
  Future<ThemePreference?> load() async => _stored;

  @override
  Future<void> save(ThemePreference mode) async {
    saved = mode;
    _stored = mode;
  }
}

ThemePreference _toPreference(final ThemeMode mode) => switch (mode) {
  ThemeMode.light => ThemePreference.light,
  ThemeMode.dark => ThemePreference.dark,
  ThemeMode.system => ThemePreference.system,
};

/// Simple fake timer service to drive periodic ticks deterministically in tests.
class FakeTimerService implements TimerService {
  final List<_PeriodicEntry> _periodicEntries = [];
  final List<_OneShotEntry> _oneShotEntries = [];

  @override
  TimerDisposable periodic(Duration interval, void Function() onTick) {
    final entry = _PeriodicEntry(interval, onTick);
    _periodicEntries.add(entry);
    return _FakeTimerHandle(() {
      if (entry.cancelled) {
        return;
      }
      entry.cancelled = true;
      _periodicEntries.remove(entry);
    });
  }

  @override
  TimerDisposable runOnce(Duration delay, void Function() onComplete) {
    final entry = _OneShotEntry(delay, onComplete);
    _oneShotEntries.add(entry);
    return _FakeTimerHandle(() {
      if (entry.cancelled) {
        return;
      }
      entry.cancelled = true;
      _oneShotEntries.remove(entry);
    });
  }

  /// Triggers all active periodic callbacks [times] times.
  void tick([int times = 1]) {
    for (int i = 0; i < times; i++) {
      final callbacks = _periodicEntries
          .where((e) => !e.cancelled)
          .map((e) => e.onTick)
          .toList();
      for (final cb in callbacks) {
        cb();
      }
    }
  }

  /// Advances fake time by [duration], triggering due timers.
  void elapse(Duration duration) {
    final int delta = duration.inMicroseconds;
    if (delta <= 0) {
      return;
    }

    for (final entry in List<_PeriodicEntry>.from(_periodicEntries)) {
      if (entry.cancelled) {
        continue;
      }
      entry.addElapsed(delta);
    }

    final pending = <_OneShotEntry>[];
    for (final entry in List<_OneShotEntry>.from(_oneShotEntries)) {
      if (entry.cancelled) {
        continue;
      }
      entry.remainingMicros -= delta;
      if (entry.remainingMicros <= 0) {
        entry.cancelled = true;
        pending.add(entry);
        _oneShotEntries.remove(entry);
      }
    }

    for (final entry in pending) {
      entry.onComplete();
    }
  }
}

class _PeriodicEntry {
  _PeriodicEntry(this.interval, this.onTick);
  final Duration interval;
  final void Function() onTick;
  bool cancelled = false;
  int _elapsedMicros = 0;

  void addElapsed(int deltaMicros) {
    if (interval.inMicroseconds <= 0) {
      return;
    }
    _elapsedMicros += deltaMicros;
    final int intervalMicros = interval.inMicroseconds;
    final int tickCount = _elapsedMicros ~/ intervalMicros;
    if (tickCount == 0) {
      return;
    }
    _elapsedMicros -= tickCount * intervalMicros;
    for (int i = 0; i < tickCount; i++) {
      onTick();
    }
  }
}

class _OneShotEntry {
  _OneShotEntry(Duration delay, this.onComplete)
    : remainingMicros = delay.inMicroseconds;
  final void Function() onComplete;
  int remainingMicros;
  bool cancelled = false;
}

class _FakeTimerHandle implements TimerDisposable {
  _FakeTimerHandle(this._onDispose);
  final void Function() _onDispose;
  @override
  void dispose() => _onDispose();
}

/// Waits until every rendered [CounterPage] exposes a [CounterCubit] whose
/// state is no longer loading.
Future<void> waitForCounterCubitsToLoad(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final Stopwatch stopwatch = Stopwatch()..start();
  final Finder counterPageFinder = find.byType(CounterPage);

  while (stopwatch.elapsed < timeout) {
    final List<Element> elements = counterPageFinder.evaluate().toList();
    if (elements.isNotEmpty) {
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

  throw StateError(
    'CounterCubit did not finish loading within ${timeout.inMilliseconds}ms',
  );
}

/// Overrides the CounterRepository in GetIt with a MockCounterRepository.
///
/// This is useful for tests that need deterministic behavior without
/// actual database operations.
void overrideCounterRepository() {
  if (getIt.isRegistered<CounterRepository>()) {
    getIt.unregister<CounterRepository>();
  }
  getIt.registerSingleton<CounterRepository>(MockCounterRepository());
}

/// Options for test setup configuration
class TestSetupOptions {
  const TestSetupOptions({
    this.overrideCounterRepository = false,
    this.setFlavorToProd = false,
    this.initialSharedPreferencesValues,
  });

  final bool overrideCounterRepository;
  final bool setFlavorToProd;
  final Map<String, Object>? initialSharedPreferencesValues;
}

/// Sets up Hive for testing. Call this in setUpAll.
///
/// Example:
/// ```dart
/// setUpAll(() async {
///   await setupHiveForTesting();
/// });
/// ```
Future<void> setupHiveForTesting() async {
  final Directory testDir = Directory.systemTemp.createTempSync('hive_test_');
  Hive.init(testDir.path);
}

/// Sets up common test dependencies. Call this in setUp.
///
/// This function:
/// - Initializes SharedPreferences mock
/// - Optionally sets flavor to prod
/// - Resets GetIt
/// - Configures dependencies
/// - Overrides network and sync services
/// - Optionally overrides counter repository
/// - Runs migration if needed
///
/// Example:
/// ```dart
/// setUp(() async {
///   await setupTestDependencies(
///     TestSetupOptions(
///       overrideCounterRepository: true,
///       setFlavorToProd: true,
///     ),
///   );
/// });
/// ```
Future<void> setupTestDependencies([
  TestSetupOptions options = const TestSetupOptions(),
]) async {
  SharedPreferences.setMockInitialValues(
    options.initialSharedPreferencesValues ?? <String, Object>{},
  );
  if (options.setFlavorToProd) {
    FlavorManager.current = Flavor.prod;
  }
  await getIt.reset(dispose: true);
  await configureDependencies();
  await overrideNetworkAndSync();
  if (options.overrideCounterRepository) {
    overrideCounterRepository();
  }
  // Run migration to avoid delays during widget test
  await getIt<SharedPreferencesMigrationService>().migrateIfNeeded();
}

/// Tears down test dependencies. Call this in tearDown.
///
/// Example:
/// ```dart
/// tearDown(() async {
///   await tearDownTestDependencies();
/// });
/// ```
Future<void> tearDownTestDependencies() async {
  await getIt.reset(dispose: true);
}

/// Overrides network and sync services with fake implementations.
///
/// This is automatically called by [setupTestDependencies] but can be
/// called separately if needed.
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
  Future<int> prune({
    int maxRetryCount = 10,
    Duration maxAge = const Duration(days: 30),
  }) async => 0;

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
}

/// Creates a fresh HiveService instance for testing.
///
/// This is useful for repository tests that need a clean HiveService
/// for each test case.
///
/// Example:
/// ```dart
/// setUp(() async {
///   hiveService = await test_helpers.createHiveService();
///   repository = MyRepository(hiveService: hiveService);
/// });
/// ```
Future<HiveService> createHiveService() async {
  final InMemorySecretStorage storage = InMemorySecretStorage();
  final HiveKeyManager keyManager = HiveKeyManager(storage: storage);
  final HiveService hiveService = HiveService(keyManager: keyManager);
  await hiveService.initialize();
  return hiveService;
}

/// Cleans up Hive boxes after tests.
///
/// Attempts to delete the specified boxes, ignoring errors if they don't exist.
///
/// Example:
/// ```dart
/// tearDown(() async {
///   await test_helpers.cleanupHiveBoxes(['my_box', 'other_box']);
/// });
/// ```
Future<void> cleanupHiveBoxes(List<String> boxNames) async {
  for (final boxName in boxNames) {
    try {
      await Hive.deleteBoxFromDisk(boxName);
    } catch (_) {
      // Box might not exist, ignore
    }
  }
}
