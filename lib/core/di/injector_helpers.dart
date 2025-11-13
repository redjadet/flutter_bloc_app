import 'dart:async';

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
