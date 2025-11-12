import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/app_scope.dart';
import 'package:flutter_bloc_app/app/router/go_router_refresh_stream.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/features.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/utils/bloc_provider_helpers.dart';
import 'package:go_router/go_router.dart';

/// Main application widget
class MyApp extends StatefulWidget {
  const MyApp({super.key, this.requireAuth = true});

  final bool requireAuth;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final FirebaseAuth _auth;
  late final GoRouterRefreshStream _authRefresh;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = _createRouter();
  }

  GoRouter _createRouter() {
    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
        path: AppRoutes.authPath,
        name: AppRoutes.auth,
        builder: (final context, final state) => const SignInPage(),
      ),
      GoRoute(
        path: AppRoutes.counterPath,
        name: AppRoutes.counter,
        builder: (final context, final state) =>
            CounterPage(title: context.l10n.homeTitle),
      ),
      GoRoute(
        path: AppRoutes.calculatorPath,
        name: AppRoutes.calculator,
        builder: (final context, final state) => BlocProvider(
          create: (_) => CalculatorCubit(
            calculator: getIt<PaymentCalculator>(),
          ),
          child: const CalculatorPage(),
        ),
        routes: [
          GoRoute(
            path: 'payment',
            name: AppRoutes.calculatorPayment,
            builder: (final context, final state) {
              final Object? extra = state.extra;
              if (extra is CalculatorCubit) {
                return BlocProvider.value(
                  value: extra,
                  child: const CalculatorPaymentPage(),
                );
              }
              return BlocProvider(
                create: (_) => CalculatorCubit(
                  calculator: getIt<PaymentCalculator>(),
                ),
                child: const CalculatorPaymentPage(),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.examplePath,
        name: AppRoutes.example,
        builder: (final context, final state) => const ExamplePage(),
      ),
      GoRoute(
        path: AppRoutes.graphqlPath,
        name: AppRoutes.graphql,
        builder: (final context, final state) =>
            BlocProviderHelpers.withAsyncInit<GraphqlDemoCubit>(
              create: () => GraphqlDemoCubit(
                repository: getIt<GraphqlDemoRepository>(),
              ),
              init: (cubit) => cubit.loadInitial(),
              child: const GraphqlDemoPage(),
            ),
      ),
      GoRoute(
        path: AppRoutes.chartsPath,
        name: AppRoutes.charts,
        builder: (final context, final state) => const ChartPage(),
      ),
      GoRoute(
        path: AppRoutes.settingsPath,
        name: AppRoutes.settings,
        builder: (final context, final state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.manageAccountPath,
        name: AppRoutes.manageAccount,
        builder: (final context, final state) => const AuthProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.profilePath,
        name: AppRoutes.profile,
        builder: (final context, final state) =>
            BlocProviderHelpers.withAsyncInit<ProfileCubit>(
              create: () => ProfileCubit(
                repository: getIt<ProfileRepository>(),
              ),
              init: (cubit) => cubit.loadProfile(),
              child: const ProfilePage(),
            ),
      ),
      GoRoute(
        path: AppRoutes.registerPath,
        name: AppRoutes.register,
        builder: (final context, final state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.loggedOutPath,
        name: AppRoutes.loggedOut,
        builder: (final context, final state) => const LoggedOutPage(),
      ),
      GoRoute(
        path: AppRoutes.chatPath,
        name: AppRoutes.chat,
        builder: (final context, final state) =>
            BlocProviderHelpers.withAsyncInit<ChatCubit>(
              create: () => ChatCubit(
                repository: getIt<ChatRepository>(),
                historyRepository: getIt<ChatHistoryRepository>(),
                initialModel: SecretConfig.huggingfaceModel,
              ),
              init: (cubit) => cubit.loadHistory(),
              child: const ChatPage(),
            ),
      ),
      GoRoute(
        path: AppRoutes.chatListPath,
        name: AppRoutes.chatList,
        builder: (final context, final state) => const ChatListPage(),
      ),
      GoRoute(
        path: AppRoutes.websocketPath,
        name: AppRoutes.websocket,
        builder: (final context, final state) => BlocProvider(
          create: (_) =>
              WebsocketCubit(repository: getIt<WebsocketRepository>()),
          child: const WebsocketDemoPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.googleMapsPath,
        name: AppRoutes.googleMaps,
        builder: (final context, final state) =>
            BlocProviderHelpers.withAsyncInit<MapSampleCubit>(
              create: () => MapSampleCubit(
                repository: getIt<MapLocationRepository>(),
              ),
              init: (cubit) => cubit.loadLocations(),
              child: const GoogleMapsSamplePage(),
            ),
      ),
      GoRoute(
        path: AppRoutes.searchPath,
        name: AppRoutes.search,
        builder: (final context, final state) => const SearchPage(),
      ),
    ];

    if (!widget.requireAuth) {
      return GoRouter(initialLocation: AppRoutes.counterPath, routes: routes);
    }

    _auth = FirebaseAuth.instance;
    _authRefresh = GoRouterRefreshStream(_auth.authStateChanges());

    return GoRouter(
      initialLocation: AppRoutes.counterPath,
      refreshListenable: _authRefresh,
      redirect: (final context, final state) {
        final FirebaseAuth auth = _auth;
        final bool loggedIn = auth.currentUser != null;
        final bool loggingIn = state.matchedLocation == AppRoutes.authPath;

        // Allow deep link navigation to proceed without redirect
        // This ensures deep links work even when user is not authenticated
        final String currentLocation = state.matchedLocation;
        final bool isDeepLinkNavigation =
            currentLocation != AppRoutes.counterPath &&
            currentLocation != AppRoutes.authPath &&
            currentLocation != '/';

        if (!loggedIn) {
          // If it's a deep link navigation, allow it to proceed
          if (isDeepLinkNavigation) {
            return null; // Allow navigation to proceed
          }
          return loggingIn ? null : AppRoutes.authPath;
        }
        if (loggingIn) {
          final bool upgradingAnonymous =
              auth.currentUser?.isAnonymous ?? false;
          if (upgradingAnonymous) {
            return null;
          }
          return AppRoutes.counterPath;
        }
        return null;
      },
      routes: routes,
    );
  }

  @override
  Widget build(final BuildContext context) => AppScope(router: _router);

  @override
  void dispose() {
    if (widget.requireAuth) {
      _authRefresh.dispose();
    }
    super.dispose();
  }
}
