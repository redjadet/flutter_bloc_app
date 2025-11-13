import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/counter/data/hive_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/data/realtime_database_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/features/remote_config/data/repositories/remote_config_repository.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Creates a CounterRepository instance.
///
/// Tries to create a Firebase-backed repository if Firebase is available,
/// otherwise falls back to Hive-backed repository.
CounterRepository createCounterRepository() {
  if (Firebase.apps.isNotEmpty) {
    // coverage:ignore-start
    try {
      final FirebaseApp app = Firebase.app();
      final FirebaseDatabase database = FirebaseDatabase.instanceFor(app: app)
        ..setPersistenceEnabled(true);
      final FirebaseAuth auth = FirebaseAuth.instanceFor(app: app);
      return RealtimeDatabaseCounterRepository(database: database, auth: auth);
    } on FirebaseException catch (error, stackTrace) {
      AppLogger.error(
        'Falling back to HiveCounterRepository',
        error,
        stackTrace,
      );
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'Falling back to HiveCounterRepository',
        error,
        stackTrace,
      );
    }
    // coverage:ignore-end
  }
  return HiveCounterRepository(hiveService: getIt<HiveService>());
}

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
  Future<void> dispose() async {}
}
