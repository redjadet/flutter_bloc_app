import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/utils/bloc_provider_helpers.dart';
import 'package:go_router/go_router.dart';

/// go_router 18+ page helpers: stable `NoTransitionPage` keyed by `state.pageKey`.
abstract final class RouteScopedPage {
  RouteScopedPage._();

  /// Page without route-owned cubit (still needs `state.pageKey` under go_router 18+).
  static Page<void> noTransition({
    required GoRouterState state,
    required Widget child,
  }) => NoTransitionPage<void>(
    key: state.pageKey,
    child: child,
  );

  /// Page with a single route-scoped cubit and optional async init.
  static Page<void> withAsyncInit<T extends BlocBase<Object?>>({
    required GoRouterState state,
    required T Function() create,
    required Widget child,
    Future<void> Function(T cubit)? init,
  }) => noTransition(
    state: state,
    child: child.routeScoped(create: create, init: init),
  );

  /// `GoRoute` whose page is always `NoTransitionPage(key: state.pageKey)`.
  static GoRoute route({
    required String path,
    required Widget Function(BuildContext context, GoRouterState state) builder,
    String? name,
    GoRouterRedirect? redirect,
    List<RouteBase> routes = const <RouteBase>[],
  }) => GoRoute(
    path: path,
    name: name,
    redirect: redirect,
    routes: routes,
    pageBuilder: (context, state) => noTransition(
      state: state,
      child: builder(context, state),
    ),
  );

  /// `GoRoute` with one route-scoped cubit owned for the page lifetime.
  static GoRoute routeWithCubit<T extends BlocBase<Object?>>({
    required String path,
    required T Function(BuildContext context, GoRouterState state) create,
    required Widget child,
    String? name,
    Future<void> Function(T cubit)? init,
    GoRouterRedirect? redirect,
    List<RouteBase> routes = const <RouteBase>[],
  }) => GoRoute(
    path: path,
    name: name,
    redirect: redirect,
    routes: routes,
    pageBuilder: (context, state) => withAsyncInit<T>(
      state: state,
      create: () => create(context, state),
      init: init,
      child: child,
    ),
  );
}

/// Nest route-scoped cubits from the leaf outward (last call = outermost).
extension RouteScopedWidgetX on Widget {
  Widget routeScoped<T extends BlocBase<Object?>>({
    required T Function() create,
    Future<void> Function(T cubit)? init,
  }) => BlocProviderHelpers.routeScopedWithAsyncInit<T>(
    create: create,
    init: init,
    child: this,
  );
}
