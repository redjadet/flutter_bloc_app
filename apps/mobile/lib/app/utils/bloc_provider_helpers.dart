import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';

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
/// For go_router route-owned cubits (go_router 18+), prefer
/// `routeScopedWithAsyncInit` with `pageBuilder` and `state.pageKey`.
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
    required T Function() create,
    required Future<void> Function(T cubit) init,
    required Widget child,
  }) => BlocProvider<T>(
    create: (_) {
      final cubit = create();
      unawaited(init(cubit));
      return cubit;
    },
    child: child,
  );

  /// Creates a BlocProvider with async initialization for use in MultiBlocProvider.
  ///
  /// This is a convenience method that returns a BlocProvider directly (without
  /// wrapping it in a Widget) for use in MultiBlocProvider's providers list.
  ///
  /// **When to use:** When you need to add a cubit with async initialization
  /// to a MultiBlocProvider's providers list.
  ///
  /// **Example:**
  /// ```dart
  /// MultiBlocProvider(
  ///   providers: [
  ///     BlocProviderHelpers.providerWithAsyncInit<CounterCubit>(
  ///       create: () => CounterCubit(repository: getIt<CounterRepository>()),
  ///       init: (cubit) => cubit.loadInitial(),
  ///     ),
  ///   ],
  ///   child: MyWidget(),
  /// )
  /// ```
  static BlocProvider<T>
  providerWithAsyncInit<T extends StateStreamableSource<Object?>>({
    required T Function() create,
    required Future<void> Function(T cubit) init,
  }) => BlocProvider<T>(
    create: (_) {
      final cubit = create();
      unawaited(init(cubit));
      return cubit;
    },
    child: const SizedBox.shrink(), // Placeholder child, not used in MultiBlocProvider
  );

  /// Creates a type-safe BlocProvider with compile-time type checking.
  ///
  /// This method provides compile-time safety by ensuring that:
  /// - The cubit type [C] extends `Cubit<S>`
  /// - The state type [S] matches the cubit's state type
  /// - Type inference works correctly
  ///
  /// **Usage Example:**
  /// ```dart
  /// BlocProviderHelpers.withCubit<CounterCubit, CounterState>(
  ///   create: () => CounterCubit(repository: getIt<CounterRepository>()),
  ///   builder: (context, cubit) => CounterPage(cubit: cubit),
  /// )
  /// ```
  static Widget withCubit<C extends Cubit<S>, S>({
    required C Function() create,
    required Widget Function(BuildContext context, C cubit) builder,
  }) => BlocProvider<C>(
    create: (_) => create(),
    child: Builder(
      builder: (context) {
        final cubit = context.cubit<C>();
        return builder(context, cubit);
      },
    ),
  );

  /// Creates a type-safe BlocProvider with async initialization.
  ///
  /// This combines type safety with async initialization for compile-time safety.
  ///
  /// **Usage Example:**
  /// ```dart
  /// BlocProviderHelpers.withCubitAsyncInit<CounterCubit, CounterState>(
  ///   create: () => CounterCubit(repository: getIt<CounterRepository>()),
  ///   init: (cubit) => cubit.loadInitial(),
  ///   builder: (context, cubit) => CounterPage(cubit: cubit),
  /// )
  /// ```
  static Widget withCubitAsyncInit<C extends Cubit<S>, S>({
    required C Function() create,
    required Future<void> Function(C cubit) init,
    required Widget Function(BuildContext context, C cubit) builder,
  }) => BlocProvider<C>(
    create: (_) {
      final cubit = create();
      unawaited(init(cubit));
      return cubit;
    },
    child: Builder(
      builder: (context) {
        final cubit = context.cubit<C>();
        return builder(context, cubit);
      },
    ),
  );

  /// Route-scoped cubit ownership for go_router pages that may rebuild mid-transition.
  ///
  /// Pair with `GoRoute.pageBuilder` and a page keyed by `GoRouteState.pageKey`
  /// (for example `NoTransitionPage`) so navigator transitions do not dispose
  /// route-scoped cubits early under go_router 18+.
  ///
  /// Prefer `Widget.routeScoped` / `RouteScopedPage` at call sites.
  static Widget routeScopedWithAsyncInit<T extends BlocBase<Object?>>({
    required T Function() create,
    required Widget child,
    Future<void> Function(T cubit)? init,
  }) => _RouteScopedAsyncInitBloc<T>(
    create: create,
    init: init,
    child: child,
  );
}

class const _RouteScopedAsyncInitBloc<T extends BlocBase<Object?>>({
  required final T Function() create,
  required final Widget child,
  final Future<void> Function(T cubit)? init,
}) extends StatefulWidget {
  @override
  State<_RouteScopedAsyncInitBloc<T>> createState() =>
      _RouteScopedAsyncInitBlocState<T>();
}

class _RouteScopedAsyncInitBlocState<T extends BlocBase<Object?>>
    extends State<_RouteScopedAsyncInitBloc<T>> {
  late final T _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = widget.create();
    final init = widget.init;
    if (init != null) {
      unawaited(init(_cubit));
    }
  }

  @override
  void dispose() {
    unawaited(_cubit.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<T>.value(value: _cubit, child: widget.child);
  }
}
