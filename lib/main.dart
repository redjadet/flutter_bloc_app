import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/counter_cubit.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/presentation/pages/home_page.dart';
import 'package:flutter_bloc_app/theme_cubit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:window_manager/window_manager.dart';
import 'package:responsive_framework/responsive_framework.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await windowManager.ensureInitialized();
    const Size minSize = Size(390, 390);
    await windowManager.setMinimumSize(minSize);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CounterCubit()..loadInitial()),
        BlocProvider(create: (_) => ThemeCubit()..loadInitial()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) => MaterialApp(
              onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                AppLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              // default shows banner in debug; hide in release automatically
              localeListResolutionCallback: (locales, supported) {
                if (locales != null && locales.isNotEmpty) {
                  // Try exact match (language+country)
                  for (final Locale sys in locales) {
                    if (supported.any(
                      (s) =>
                          s.languageCode == sys.languageCode &&
                          (s.countryCode == null ||
                              s.countryCode == sys.countryCode),
                    )) {
                      return Locale(sys.languageCode, sys.countryCode);
                    }
                  }
                  // Try language-only match
                  for (final Locale sys in locales) {
                    final match = supported.firstWhere(
                      (s) => s.languageCode == sys.languageCode,
                      orElse: () => const Locale('en'),
                    );
                    if (match.languageCode != 'en' ||
                        supported.any((s) => s.languageCode == 'en')) {
                      return match;
                    }
                  }
                }
                // Fallback to English
                return const Locale('en');
              },
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF6750A4),
                ),
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF6750A4),
                  brightness: Brightness.dark,
                ),
              ),
              themeMode: themeMode,
              builder: (context, child) {
                final Widget constrained = ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 390,
                    minHeight: 390,
                  ),
                  child: child ?? const SizedBox.shrink(),
                );
                return ResponsiveBreakpoints.builder(
                  child: constrained,
                  breakpoints: const [
                    Breakpoint(start: 0, end: 799, name: MOBILE),
                    Breakpoint(start: 800, end: 1199, name: TABLET),
                    Breakpoint(
                      start: 1200,
                      end: double.infinity,
                      name: DESKTOP,
                    ),
                  ],
                );
              },
              home: child,
            ),
          );
        },
        child: Builder(
          builder: (context) =>
              MyHomePage(title: AppLocalizations.of(context).homeTitle),
        ),
      ),
    );
  }
}
