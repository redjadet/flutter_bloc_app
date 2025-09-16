import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/constants.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

/// Application configuration and theme setup
class AppConfig {
  /// Creates the MaterialApp with all necessary configurations
  static Widget createMaterialApp({
    required ThemeMode themeMode,
    required GoRouter router,
    Widget? child,
  }) {
    return MaterialApp.router(
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      localeListResolutionCallback: _localeListResolutionCallback,
      theme: _createLightTheme(),
      darkTheme: _createDarkTheme(),
      themeMode: themeMode,
      builder: (context, appChild) => _createResponsiveBuilder(appChild ?? child),
      routerConfig: router,
    );
  }

  /// Creates light theme
  static ThemeData _createLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primarySeedColor,
      ),
    );
  }

  /// Creates dark theme
  static ThemeData _createDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primarySeedColor,
        brightness: Brightness.dark,
      ),
    );
  }

  /// Creates responsive builder with constraints and breakpoints
  static Widget _createResponsiveBuilder(Widget? child) {
    final Widget constrained = ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: AppConstants.minContentWidth,
        minHeight: AppConstants.minContentHeight,
      ),
      child: child ?? const SizedBox.shrink(),
    );

    return ResponsiveBreakpoints.builder(
      child: constrained,
      breakpoints: const [
        Breakpoint(
          start: 0,
          end: AppConstants.mobileBreakpoint - 1,
          name: MOBILE,
        ),
        Breakpoint(
          start: AppConstants.mobileBreakpoint,
          end: AppConstants.tabletBreakpoint - 1,
          name: TABLET,
        ),
        Breakpoint(
          start: AppConstants.tabletBreakpoint,
          end: double.infinity,
          name: DESKTOP,
        ),
      ],
    );
  }

  /// Handles locale resolution with fallback logic
  static Locale? _localeListResolutionCallback(
    List<Locale>? locales,
    Iterable<Locale> supported,
  ) {
    if (locales != null && locales.isNotEmpty) {
      // Try exact match (language+country)
      for (final Locale sys in locales) {
        if (supported.any(
          (s) =>
              s.languageCode == sys.languageCode &&
              (s.countryCode == null || s.countryCode == sys.countryCode),
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
  }
}
