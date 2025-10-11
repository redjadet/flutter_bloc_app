import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/flavor.dart';
import 'package:flutter_bloc_app/features/features.dart';
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
  FirebaseAuth? _auth;
  _GoRouterRefreshStream? _authRefresh;
  late GoRouter _router;

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
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: AppRoutes.counterPath,
        name: AppRoutes.counter,
        builder: (context, state) =>
            CounterPage(title: AppLocalizations.of(context).homeTitle),
      ),
      GoRoute(
        path: AppRoutes.examplePath,
        name: AppRoutes.example,
        builder: (context, state) => const ExamplePage(),
      ),
      GoRoute(
        path: AppRoutes.graphqlPath,
        name: AppRoutes.graphql,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              GraphqlDemoCubit(repository: getIt<GraphqlDemoRepository>())
                ..loadInitial(),
          child: const GraphqlDemoPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.chartsPath,
        name: AppRoutes.charts,
        builder: (context, state) => const ChartPage(),
      ),
      GoRoute(
        path: AppRoutes.settingsPath,
        name: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.profilePath,
        name: AppRoutes.profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.chatPath,
        name: AppRoutes.chat,
        builder: (context, state) => BlocProvider(
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
        builder: (context, state) => BlocProvider(
          create: (_) =>
              WebsocketCubit(repository: getIt<WebsocketRepository>()),
          child: const WebsocketDemoPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.googleMapsPath,
        name: AppRoutes.googleMaps,
        builder: (context, state) => BlocProvider(
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
    _authRefresh = _GoRouterRefreshStream(_auth!.authStateChanges());

    return GoRouter(
      initialLocation: AppRoutes.counterPath,
      refreshListenable: _authRefresh,
      redirect: (context, state) {
        final FirebaseAuth auth = _auth!;
        final bool loggedIn = auth.currentUser != null;
        final bool loggingIn = state.matchedLocation == AppRoutes.authPath;

        if (!loggedIn) {
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
  Widget build(BuildContext context) {
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
      ],
      child: DeepLinkListener(
        router: _router,
        child: ScreenUtilInit(
          designSize: AppConstants.designSize,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            UI.markScreenUtilReady();
            return BlocBuilder<LocaleCubit, Locale?>(
              builder: (context, locale) {
                return BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, themeMode) => AppConfig.createMaterialApp(
                    themeMode: themeMode,
                    router: _router,
                    locale: locale,
                    child: child,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _authRefresh?.dispose();
    super.dispose();
  }
}

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
