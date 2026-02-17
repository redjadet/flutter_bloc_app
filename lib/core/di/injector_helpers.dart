import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:get_it/get_it.dart';

/// Helper function to register a lazy singleton if it's not already registered.
///
/// This prevents duplicate registrations and allows safe re-registration
/// during testing or hot reload scenarios.
void registerLazySingletonIfAbsent<T extends Object>(
  final T Function() factory, {
  final FutureOr<void> Function(T instance)? dispose,
}) {
  final GetIt getIt = GetIt.instance;
  if (!getIt.isRegistered<T>()) {
    getIt.registerLazySingleton<T>(factory, dispose: dispose);
  }
}

/// Creates a remote repository with Firebase error handling.
///
/// Returns null if Firebase is not available or if creation fails.
/// Logs errors appropriately for debugging.
///
/// **Usage:**
/// ```dart
/// final remoteRepo = createRemoteRepositoryOrNull(
///   context: 'CounterRepository',
///   factory: () {
///     final app = Firebase.app();
///     final database = FirebaseDatabase.instanceFor(app: app);
///     final auth = FirebaseAuth.instanceFor(app: app);
///     return RealtimeDatabaseCounterRepository(database: database, auth: auth);
///   },
/// );
/// ```
T? createRemoteRepositoryOrNull<T>({
  required final String context,
  required final T Function() factory,
}) {
  if (Firebase.apps.isEmpty) {
    return null;
  }
  // coverage:ignore-start
  try {
    return factory();
  } on Exception catch (error, stackTrace) {
    AppLogger.error(
      'Creating remote $context failed',
      error,
      stackTrace,
    );
    return null;
  }
  // coverage:ignore-end
}
