import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Helper utilities for creating BlocProviders with common patterns.
///
/// **Why this exists:** Reduces boilerplate when creating BlocProviders that need
/// async initialization (e.g., loading initial data). The initialization is fire-and-forget
/// using `unawaited()` to avoid blocking widget tree construction.
///
/// **Usage Example:**
/// ```dart
/// BlocProviderHelpers.withAsyncInit<CounterCubit>(
///   create: () => CounterCubit(repository: getIt<CounterRepository>()),
///   init: (cubit) => cubit.loadInitial(), // Async initialization
///   child: CounterPage(),
/// )
/// ```
///
/// **Why use `unawaited()`:** The initialization is intentionally fire-and-forget
/// because we want the widget tree to build immediately while data loads in the background.
/// Errors are handled within the cubit's error handling mechanism.
class BlocProviderHelpers {
  BlocProviderHelpers._();

  /// Creates a BlocProvider with async initialization.
  ///
  /// The initialization function is called with `unawaited()` to avoid blocking
  /// widget tree construction. This allows the UI to render immediately while
  /// the cubit loads data in the background.
  ///
  /// **When to use:** When a cubit needs to load initial data (e.g., from a repository)
  /// but you don't want to block the widget tree from rendering.
  ///
  /// **Error handling:** Errors during initialization should be handled within
  /// the cubit's error handling mechanism (e.g., `CubitExceptionHandler`).
  static Widget withAsyncInit<T extends StateStreamableSource<Object?>>({
    required final T Function() create,
    required final Future<void> Function(T cubit) init,
    required final Widget child,
  }) => BlocProvider<T>(
    create: (_) {
      final cubit = create();
      unawaited(init(cubit));
      return cubit;
    },
    child: child,
  );
}
