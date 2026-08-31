import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc_app/app/auth/session_lifecycle_coordinator.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/router/app_route_auth_gate.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/router/deferred_pages/google_maps_page.dart'
    deferred as google_maps_page;
import 'package:flutter_bloc_app/app/router/deferred_pages/realtime_market_page.dart'
    deferred as realtime_market_page;
import 'package:flutter_bloc_app/app/router/deferred_pages/websocket_page.dart'
    deferred as websocket_page;
import 'package:flutter_bloc_app/app/router/route_auth_policy.dart';
import 'package:flutter_bloc_app/app/router/route_scoped_page.dart';
import 'package:flutter_bloc_app/app/widgets/deferred_page.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location_repository.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/realtime_market_repository.dart';
import 'package:flutter_bloc_app/features/search/domain/search_repository.dart';
import 'package:flutter_bloc_app/features/search/presentation/pages/search_page.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_bloc_app/features/supabase_auth/presentation/cubit/supabase_auth_cubit.dart';
import 'package:flutter_bloc_app/features/supabase_auth/presentation/pages/supabase_auth_page.dart';
import 'package:flutter_bloc_app/features/todo_list/todo_list.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/walletconnect_auth_repository.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/presentation/cubit/walletconnect_auth_cubit.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/presentation/pages/walletconnect_auth_page.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_repository.dart';
import 'package:go_router/go_router.dart';

List<RouteBase> createAuxiliaryRoutes(AuxiliaryRouteFactory factory) =>
    factory.createRoutes();

class const AuxiliaryRouteFactory({
  required final SearchRepository searchRepository,
  required final TimerService timerService,
  required final TodoRepository Function() createTodoRepository,
  required final AuthRepository authRepository,
  required final WalletConnectAuthRepository walletConnectAuthRepository,
  required final SupabaseAuthRepository supabaseAuthRepository,
  required final SessionLifecycleCoordinator? sessionCoordinator,
  required final WebsocketRepository websocketRepository,
  required final MapLocationRepository mapLocationRepository,
  required final RealtimeMarketRepository Function()
  createRealtimeMarketRepository,
}) {
  List<RouteBase> createRoutes() => <RouteBase>[
    RouteScopedPage.route(
      path: AppRoutes.websocketPath,
      name: AppRoutes.websocket,
      builder: (_, _) => DeferredPage(
        loadLibrary: websocket_page.loadLibrary,
        builder: (context) => websocket_page.buildWebsocketPage(
          repository: websocketRepository,
        ),
      ),
    ),
    RouteScopedPage.route(
      path: AppRoutes.realtimeMarketPath,
      name: AppRoutes.realtimeMarket,
      builder: (_, _) => DeferredPage(
        loadLibrary: realtime_market_page.loadLibrary,
        builder: (context) => realtime_market_page.buildRealtimeMarketPage(
          createRepository: createRealtimeMarketRepository,
        ),
      ),
    ),
    RouteScopedPage.route(
      path: AppRoutes.googleMapsPath,
      name: AppRoutes.googleMaps,
      builder: (_, _) => DeferredPage(
        loadLibrary: google_maps_page.loadLibrary,
        builder: (context) => google_maps_page.buildGoogleMapsPage(
          repository: mapLocationRepository,
        ),
      ),
    ),
    RouteScopedPage.route(
      path: AppRoutes.searchPath,
      name: AppRoutes.search,
      builder: (_, _) => SearchPage(
        repository: searchRepository,
        timerService: timerService,
      ),
    ),
    RouteScopedPage.routeWithCubit<TodoListCubit>(
      path: AppRoutes.todoListPath,
      name: AppRoutes.todoList,
      create: (_, _) => TodoListCubit(
        repository: createTodoRepository(),
        timerService: timerService,
      ),
      init: (cubit) => cubit.loadInitial(),
      child: const TodoListPage(),
    ),
    RouteScopedPage.route(
      path: AppRoutes.walletconnectAuthPath,
      name: AppRoutes.walletconnectAuth,
      builder: (context, _) {
        final l10n = context.l10n;
        return AppRouteAuthGate(
          policy: AppRoutePolicies.walletconnectAuth,
          getCurrentUser: () => authRepository.currentUser,
          authStateChanges: authRepository.authStateChanges,
          authPath: AppRoutes.authPath,
          child: const WalletConnectAuthPage().routeScoped(
            create: () => WalletConnectAuthCubit(
              repository: walletConnectAuthRepository,
              l10n: l10n,
            ),
            init: (cubit) => cubit.loadLinkedWallet(),
          ),
        );
      },
    ),
    RouteScopedPage.route(
      path: AppRoutes.supabaseAuthPath,
      name: AppRoutes.supabaseAuth,
      builder: (context, state) {
        final l10n = context.l10n;
        return SupabaseAuthPage(
          redirectAfterLogin: state.uri.queryParameters['redirect'],
        ).routeScoped(
          create: () => SupabaseAuthCubit(
            repository: supabaseAuthRepository,
            l10n: l10n,
            sessionCoordinator: sessionCoordinator,
          ),
          init: (cubit) => cubit.loadSession(),
        );
      },
    ),
  ];
}
