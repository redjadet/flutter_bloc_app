import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/constants.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

/// Application configuration and theme setup
class AppConfig {
  /// Creates the MaterialApp with all necessary configurations
  static Widget createMaterialApp({
    required final ThemeMode themeMode,
    required final GoRouter router,
    final Locale? locale,
  }) => MaterialApp.router(
    onGenerateTitle: (final ctx) => ctx.l10n.appTitle,
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      AppLocalizations.delegate,
      FirebaseUILocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    localeListResolutionCallback: _localeListResolutionCallback,
    locale: locale,
    theme: _createLightTheme(),
    darkTheme: _createDarkTheme(),
    themeMode: themeMode,
    builder: (final context, final appChild) =>
        appChild ?? const SizedBox.shrink(),
    routerConfig: router,
  );

  /// Creates light theme
  static ThemeData _createLightTheme() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppConstants.primarySeedColor),
  );

  /// Creates dark theme
  static ThemeData _createDarkTheme() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppConstants.primarySeedColor,
      brightness: Brightness.dark,
    ),
  );

  static const Locale _defaultLocale = Locale('en');

  /// Handles locale resolution with fallback logic
  static Locale? _localeListResolutionCallback(
    final List<Locale>? locales,
    final Iterable<Locale> supported,
  ) {
    if (locales == null || locales.isEmpty) {
      return _defaultLocale;
    }

    final supportedLocales = supported.toList();

    for (final locale in locales) {
      final matchingLocale = supportedLocales.firstWhere(
        (final supportedLocale) =>
            supportedLocale.languageCode == locale.languageCode &&
            (supportedLocale.countryCode == locale.countryCode ||
                supportedLocale.countryCode == null),
        orElse: () => const Locale('unsupported'),
      );

      if (matchingLocale.languageCode != 'unsupported') {
        return locale;
      }
    }

    for (final locale in locales) {
      final matchingLocale = supportedLocales.firstWhere(
        (final supportedLocale) =>
            supportedLocale.languageCode == locale.languageCode,
        orElse: () => const Locale('unsupported'),
      );

      if (matchingLocale.languageCode != 'unsupported') {
        return matchingLocale;
      }
    }

    return _defaultLocale;
  }

  @visibleForTesting
  static Locale? resolveLocales(
    final List<Locale>? locales,
    final Iterable<Locale> supported,
  ) => _localeListResolutionCallback(locales, supported) ?? _defaultLocale;
}
