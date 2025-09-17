import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/flavor.dart';
import 'package:flutter_bloc_app/features/features.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/domain/locale_repository.dart';
import 'package:flutter_bloc_app/shared/domain/theme_repository.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Main application widget
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router = GoRouter(
    routes: [
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
        path: AppRoutes.chatPath,
        name: AppRoutes.chat,
        builder: (context, state) => BlocProvider(
          create: (_) => ChatCubit(
            repository: getIt<ChatRepository>(),
            initialModel: SecretConfig.huggingfaceModel,
          ),
          child: const ChatPage(),
        ),
      ),
    ],
  );

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
      child: ScreenUtilInit(
        designSize: AppConstants.designSize,
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
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
    );
  }
}
