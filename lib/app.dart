import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/features.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/domain/theme_repository.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
          )..loadInitial(),
        ),
        BlocProvider(
          create: (_) => ThemeCubit(repository: getIt<ThemeRepository>())..loadInitial(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: AppConstants.designSize,
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) => AppConfig.createMaterialApp(
              themeMode: themeMode,
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
        child: Builder(
          builder: (context) => CounterPage(title: AppLocalizations.of(context).homeTitle),
        ),
      ),
    );
  }
}
