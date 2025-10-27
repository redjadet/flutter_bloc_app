import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/features.dart';
import 'package:flutter_bloc_app/features/remote_config/presentation/cubit/remote_config_cubit.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AppScope extends StatelessWidget {
  const AppScope({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(final BuildContext context) {
    // Ensure DI is configured when running tests that directly pump MyApp
    ensureConfigured();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final cubit = CounterCubit(
              repository: getIt<CounterRepository>(),
              timerService: getIt(),
              loadDelay: FlavorManager.I.isDev
                  ? AppConstants.devSkeletonDelay
                  : Duration.zero,
            );
            unawaited(cubit.loadInitial());
            return cubit;
          },
        ),
        BlocProvider(
          create: (_) {
            final cubit = LocaleCubit(repository: getIt<LocaleRepository>());
            unawaited(cubit.loadInitial());
            return cubit;
          },
        ),
        BlocProvider(
          create: (_) {
            final cubit = ThemeCubit(repository: getIt<ThemeRepository>());
            unawaited(cubit.loadInitial());
            return cubit;
          },
        ),
        BlocProvider(
          create: (_) {
            final cubit = getIt<RemoteConfigCubit>();
            unawaited(cubit.initialize());
            return cubit;
          },
        ),
      ],
      child: DeepLinkListener(
        router: router,
        child: ScreenUtilInit(
          designSize: AppConstants.designSize,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (final context, final child) {
            UI.screenUtilReady = true;
            return BlocBuilder<LocaleCubit, Locale?>(
              builder: (final context, final locale) =>
                  BlocBuilder<ThemeCubit, ThemeMode>(
                    builder: (final context, final themeMode) =>
                        AppConfig.createMaterialApp(
                          themeMode: themeMode,
                          router: router,
                          locale: locale,
                        ),
                  ),
            );
          },
        ),
      ),
    );
  }
}
