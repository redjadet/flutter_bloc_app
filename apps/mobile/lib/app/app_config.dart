import 'dart:ui' show PointerDeviceKind;

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/theme/theme.dart';
import 'package:flutter_bloc_app/l10n/app_localization_delegates.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

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
    required ThemeMode themeMode,
    required GoRouter router,
    Locale? locale,
    TransitionBuilder? appOverlayBuilder,
  }) => MaterialApp.router(
    onGenerateTitle: (ctx) => ctx.l10n.appTitle,
    localizationsDelegates: const [
      ...appLocalizationDelegates,
      FirebaseUILocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    localeListResolutionCallback: _localeListResolutionCallback,
    locale: locale,
    theme: _applyTestThemeOverrides(AppTheme.lightTheme()),
    darkTheme: _applyTestThemeOverrides(AppTheme.darkTheme()),
    themeMode: themeMode,
    scrollBehavior: const _AppScrollBehavior(),
    builder: (context, appChild) {
      Widget result = appChild ?? const SizedBox.shrink();

      final locale = Localizations.maybeLocaleOf(context);
      final isArabic = locale?.languageCode == 'ar';

      if (isArabic) {
        final ThemeData baseTheme = Theme.of(context);
        final ThemeData arabicTheme = baseTheme.copyWith(
          textTheme: AppTheme.createArabicTextTheme(baseTheme.textTheme),
        );
        final Widget themedChild = result;
        result = Theme(
          data: arabicTheme,
          child: Builder(
            builder: (themedContext) =>
                buildAppMixScope(themedContext, child: themedChild),
          ),
        );
      } else {
        result = buildAppMixScope(context, child: result);
      }

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

      // Mix, genui, and firebase_ui_auth still import package:flutter/material.dart.
      // ignore: deprecated_member_use -- official shim until those packages migrate
      return MaterialUiCompatibilityBridge(child: result);
    },
    routerConfig: router,
  );

  static const Locale _defaultLocale = Locale('en');

  /// Handles locale resolution with fallback logic
  static Locale? _localeListResolutionCallback(
    List<Locale>? locales,
    Iterable<Locale> supported,
  ) {
    if (locales == null || locales.isEmpty) {
      return _defaultLocale;
    }

    final supportedLocales = supported.toList();

    for (final locale in locales) {
      final matchingLocale = supportedLocales.firstWhere(
        (supportedLocale) =>
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
        (supportedLocale) =>
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
    List<Locale>? locales,
    Iterable<Locale> supported,
  ) => _localeListResolutionCallback(locales, supported) ?? _defaultLocale;

  /// Skips M3 [InkSparkle] splashes in widget/integration test bindings.
  ///
  /// Linux CI widget tests use a SkSL backend while `ink_sparkle.frag` may ship
  /// Vulkan-only stages, which throws when tapping Material buttons.
  static ThemeData _applyTestThemeOverrides(ThemeData theme) {
    if (!_isTestEnvironment()) {
      return theme;
    }
    return theme.copyWith(splashFactory: NoSplash.splashFactory);
  }

  /// Detects if we're running in a test environment.
  ///
  /// This prevents the performance overlay from showing during golden/widget tests.
  static bool _isTestEnvironment() {
    // Check for common test environment indicators
    try {
      final env = platformEnvironment();
      return env.containsKey('FLUTTER_TEST') ||
          env.containsKey('DART_TEST_CONFIG') ||
          // Check if WidgetsBinding is a test binding (without importing flutter_test)
          WidgetsBinding.instance.runtimeType.toString().contains('Test');
    } on Exception {
      // If we can't determine, assume not in test
      return false;
    }
  }
}

class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };
}
