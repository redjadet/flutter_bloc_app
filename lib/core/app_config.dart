import 'dart:io';

import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/theme/theme.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

/// Application configuration and theme setup
class AppConfig {
  /// Whether the performance overlay is enabled.
  ///
  /// Can be configured via the `ENABLE_PERFORMANCE_OVERLAY` environment variable.
  /// Defaults to `false` (disabled).
  ///
  /// To enable, run with: `flutter run --dart-define=ENABLE_PERFORMANCE_OVERLAY=true`
  static bool get _isPerformanceOverlayEnabled =>
      const bool.fromEnvironment('ENABLE_PERFORMANCE_OVERLAY');

  /// Creates the MaterialApp with all necessary configurations
  static Widget createMaterialApp({
    required final ThemeMode themeMode,
    required final GoRouter router,
    final Locale? locale,
    final TransitionBuilder? appOverlayBuilder,
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
    theme: AppTheme.lightTheme(),
    darkTheme: AppTheme.darkTheme(),
    themeMode: themeMode,
    builder: (final context, final appChild) {
      Widget result = appChild ?? const SizedBox.shrink();

      // Add performance overlay if enabled (but not during tests)
      // Tests use kDebugMode=true, so we check for test environment
      if (_isPerformanceOverlayEnabled && !_isTestEnvironment()) {
        result = Stack(
          children: [
            result,
            // Center the overlay and allow click-through
            Center(
              child: IgnorePointer(
                child: ColoredBox(
                  color: Theme.of(
                    context,
                  ).colorScheme.scrim.withValues(alpha: 0.7),
                  child: PerformanceOverlay.allEnabled(),
                ),
              ),
            ),
          ],
        );
      }

      if (appOverlayBuilder != null) {
        result = appOverlayBuilder(context, result);
      }

      return result;
    },
    routerConfig: router,
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

  /// Detects if we're running in a test environment.
  ///
  /// This prevents the performance overlay from showing during golden/widget tests.
  static bool _isTestEnvironment() {
    // Check for common test environment indicators
    try {
      return Platform.environment.containsKey('FLUTTER_TEST') ||
          Platform.environment.containsKey('DART_TEST_CONFIG') ||
          // Check if WidgetsBinding is a test binding (without importing flutter_test)
          WidgetsBinding.instance.runtimeType.toString().contains('Test');
    } on Exception {
      // If we can't determine, assume not in test
      return false;
    }
  }
}
