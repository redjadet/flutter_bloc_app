import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/features.dart';
import 'package:flutter_bloc_app/features/remote_config/presentation/cubit/remote_config_cubit.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  late final _GoRouterRefreshStream _authRefresh;
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
            CounterPage(title: AppLocalizations.of(context).homeTitle),
      ),
      GoRoute(
        path: AppRoutes.examplePath,
        name: AppRoutes.example,
        builder: (final context, final state) => const ExamplePage(),
      ),
      GoRoute(
        path: AppRoutes.graphqlPath,
        name: AppRoutes.graphql,
        builder: (final context, final state) => BlocProvider(
          create: (_) =>
              GraphqlDemoCubit(repository: getIt<GraphqlDemoRepository>())
                ..loadInitial(),
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
        path: AppRoutes.profilePath,
        name: AppRoutes.profile,
        builder: (final context, final state) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.chatPath,
        name: AppRoutes.chat,
        builder: (final context, final state) => BlocProvider(
          create: (_) => ChatCubit(
            repository: getIt<ChatRepository>(),
            historyRepository: getIt<ChatHistoryRepository>(),
            initialModel: SecretConfig.huggingfaceModel,
          )..loadHistory(),
          child: const ChatPage(),
        ),
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
        builder: (final context, final state) => BlocProvider(
          create: (_) =>
              MapSampleCubit(repository: getIt<MapLocationRepository>())
                ..loadLocations(),
          child: const GoogleMapsSamplePage(),
        ),
      ),
    ];

    if (!widget.requireAuth) {
      return GoRouter(initialLocation: AppRoutes.counterPath, routes: routes);
    }

    _auth = FirebaseAuth.instance;
    _authRefresh = _GoRouterRefreshStream(_auth.authStateChanges());

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
  Widget build(final BuildContext context) {
    // Ensure DI is configured when running tests that directly pump MyApp
    ensureConfigured();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CounterCubit(
            repository: getIt<CounterRepository>(),
            timerService: getIt(),
            loadDelay: FlavorManager.I.isDev
                ? AppConstants.devSkeletonDelay
                : Duration.zero,
          )..loadInitial(),
        ),
        BlocProvider(
          create: (_) =>
              LocaleCubit(repository: getIt<LocaleRepository>())..loadInitial(),
        ),
        BlocProvider(
          create: (_) =>
              ThemeCubit(repository: getIt<ThemeRepository>())..loadInitial(),
        ),
        BlocProvider(create: (_) => getIt<RemoteConfigCubit>()..initialize()),
      ],
      child: DeepLinkListener(
        router: _router,
        child: ScreenUtilInit(
          designSize: AppConstants.designSize,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (final context, final child) {
            UI.markScreenUtilReady();
            return BlocBuilder<LocaleCubit, Locale?>(
              builder: (final context, final locale) =>
                  BlocBuilder<ThemeCubit, ThemeMode>(
                    builder: (final context, final themeMode) =>
                        AppConfig.createMaterialApp(
                          themeMode: themeMode,
                          router: _router,
                          locale: locale,
                        ),
                  ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (widget.requireAuth) {
      _authRefresh.dispose();
    }
    super.dispose();
  }
}

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(final Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
