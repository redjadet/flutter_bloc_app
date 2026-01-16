import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/counter/data/hive_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/data/offline_first_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/data/realtime_database_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/features/remote_config/data/repositories/remote_config_repository.dart';
import 'package:flutter_bloc_app/features/todo_list/data/hive_todo_repository.dart';
import 'package:flutter_bloc_app/features/todo_list/data/offline_first_todo_repository.dart';
import 'package:flutter_bloc_app/features/todo_list/data/realtime_database_todo_repository.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_repository.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';

/// Creates a CounterRepository instance.
///
/// Tries to create a Firebase-backed repository if Firebase is available,
/// otherwise falls back to Hive-backed repository.
CounterRepository createCounterRepository() {
  final HiveCounterRepository localRepository = HiveCounterRepository(
    hiveService: getIt<HiveService>(),
  );
  final CounterRepository? remoteRepository =
      _createRemoteCounterRepositoryOrNull();
  return OfflineFirstCounterRepository(
    localRepository: localRepository,
    remoteRepository: remoteRepository,
    pendingSyncRepository: getIt<PendingSyncRepository>(),
    registry: getIt<SyncableRepositoryRegistry>(),
  );
}

CounterRepository? _createRemoteCounterRepositoryOrNull() =>
    createRemoteRepositoryOrNull<CounterRepository>(
      context: 'counter repository',
      factory: () {
        final FirebaseApp app = Firebase.app();
        // Persistence is enabled in FirebaseBootstrapService.initializeFirebase()
        final FirebaseDatabase database = FirebaseDatabase.instanceFor(
          app: app,
        );
        final FirebaseAuth auth = FirebaseAuth.instanceFor(app: app);
        return RealtimeDatabaseCounterRepository(
          database: database,
          auth: auth,
        );
      },
    );

/// Creates a TodoRepository instance.
///
/// Uses offline-first architecture: local Hive storage with optional remote Firebase sync.
TodoRepository createTodoRepository() {
  final HiveTodoRepository localRepository = HiveTodoRepository(
    hiveService: getIt<HiveService>(),
  );
  final TodoRepository? remoteRepository = _createRemoteTodoRepositoryOrNull();
  return OfflineFirstTodoRepository(
    localRepository: localRepository,
    remoteRepository: remoteRepository,
    pendingSyncRepository: getIt<PendingSyncRepository>(),
    registry: getIt<SyncableRepositoryRegistry>(),
  );
}

TodoRepository? _createRemoteTodoRepositoryOrNull() =>
    createRemoteRepositoryOrNull<TodoRepository>(
      context: 'todo repository',
      factory: () {
        final FirebaseApp app = Firebase.app();
        // Persistence is enabled in FirebaseBootstrapService.initializeFirebase()
        final FirebaseDatabase database = FirebaseDatabase.instanceFor(
          app: app,
        );
        final FirebaseAuth auth = FirebaseAuth.instanceFor(app: app);
        return RealtimeDatabaseTodoRepository(database: database, auth: auth);
      },
    );

/// Creates a RemoteConfigRepository instance.
///
/// Tries to create a Firebase-backed repository if Firebase is available,
/// otherwise creates a fake implementation for testing.
RemoteConfigRepository createRemoteConfigRepository() {
  try {
    // Try to create with Firebase if available
    return RemoteConfigRepository(FirebaseRemoteConfig.instance);
  } on Exception {
    // If Firebase is not available (e.g., in tests), create a fake implementation
    return FakeRemoteConfigRepository();
  }
}

/// Fake implementation of RemoteConfigRepository for testing.
class FakeRemoteConfigRepository implements RemoteConfigRepository {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> forceFetch() async {}

  @override
  String getString(final String key) => '';

  @override
  bool getBool(final String key) => false;

  @override
  int getInt(final String key) => 0;

  @override
  double getDouble(final String key) => 0;

  @override
  Future<void> clearCache() async {}

  @override
  Future<void> dispose() async {}
}
