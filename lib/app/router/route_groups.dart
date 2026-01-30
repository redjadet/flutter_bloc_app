import 'package:flutter_bloc_app/app/router/deferred_pages/google_maps_page.dart'
    deferred as google_maps_page;
import 'package:flutter_bloc_app/app/router/deferred_pages/websocket_page.dart'
    deferred as websocket_page;
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/search/domain/search_repository.dart';
import 'package:flutter_bloc_app/features/search/presentation/pages/search_page.dart';
import 'package:flutter_bloc_app/features/todo_list/todo_list.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/walletconnect_auth_repository.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/presentation/cubit/walletconnect_auth_cubit.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/presentation/pages/walletconnect_auth_page.dart';
import 'package:flutter_bloc_app/shared/utils/bloc_provider_helpers.dart';
import 'package:flutter_bloc_app/shared/widgets/deferred_page.dart';
import 'package:go_router/go_router.dart';

List<GoRoute> createAuxiliaryRoutes() => <GoRoute>[
  GoRoute(
    path: AppRoutes.websocketPath,
    name: AppRoutes.websocket,
    builder: (final context, final state) => DeferredPage(
      loadLibrary: websocket_page.loadLibrary,
      builder: (final context) => websocket_page.buildWebsocketPage(),
    ),
  ),
  GoRoute(
    path: AppRoutes.googleMapsPath,
    name: AppRoutes.googleMaps,
    builder: (final context, final state) => DeferredPage(
      loadLibrary: google_maps_page.loadLibrary,
      builder: (final context) => google_maps_page.buildGoogleMapsPage(),
    ),
  ),
  GoRoute(
    path: AppRoutes.searchPath,
    name: AppRoutes.search,
    builder: (final context, final state) => SearchPage(
      repository: getIt<SearchRepository>(),
      timerService: getIt<TimerService>(),
    ),
  ),
  GoRoute(
    path: AppRoutes.todoListPath,
    name: AppRoutes.todoList,
    builder: (final context, final state) =>
        BlocProviderHelpers.withAsyncInit<TodoListCubit>(
          create: () => TodoListCubit(
            repository: getIt<TodoRepository>(),
            timerService: getIt<TimerService>(),
          ),
          init: (final cubit) => cubit.loadInitial(),
          child: const TodoListPage(),
        ),
  ),
  GoRoute(
    path: AppRoutes.walletconnectAuthPath,
    name: AppRoutes.walletconnectAuth,
    builder: (final context, final state) =>
        BlocProviderHelpers.withAsyncInit<WalletConnectAuthCubit>(
          create: () => WalletConnectAuthCubit(
            repository: getIt<WalletConnectAuthRepository>(),
          ),
          init: (final cubit) => cubit.loadLinkedWallet(),
          child: const WalletConnectAuthPage(),
        ),
  ),
];
