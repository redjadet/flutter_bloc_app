import 'package:design_system/design_system.dart';
import 'package:flutter_bloc_app/app/config/app_constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

/// Named decorative colors for confetti/particle effects; not UI theme colors.
const Color _confettiGreen = Color(0xFF4CAF50);
const Color _confettiBlue = Color(0xFF2196F3);
const Color _confettiPink = Color(0xFFE91E63);
const Color _confettiOrange = Color(0xFFFF9800);
const Color _confettiPurple = Color(0xFF9C27B0);

/// Default decorative particle colors (confetti, etc.); not UI theme colors.
/// Use for [ConfettiTheme.particleColors] and as fallback when extension is null.
const List<Color> defaultConfettiParticleColors = [
  _confettiGreen,
  _confettiBlue,
  _confettiPink,
  _confettiOrange,
  _confettiPurple,
];

/// Application theme factory.
///
/// Single place for [ThemeData], light/dark [ColorScheme], and [TextTheme].
/// Used by AppConfig when building MaterialApp.
///
/// `google_fonts` 9+ returns `material_ui` [TextTheme] (not `flutter/material`).
class AppTheme {
  new _();

  /// Bundled Arabic font family.
  static const String arabicFontFamily = 'Cairo';

  /// Light theme for the app.
  static ThemeData lightTheme() => _withComponentThemes(
    ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primarySeedColor,
      ),
      textTheme: createAppTextTheme(Brightness.light),
      extensions: const <ThemeExtension<dynamic>>[
        ConfettiTheme(particleColors: defaultConfettiParticleColors),
      ],
    ),
  );

  /// Dark theme for the app.
  static ThemeData darkTheme() => _withComponentThemes(
    ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primarySeedColor,
        brightness: Brightness.dark,
      ),
      textTheme: createAppTextTheme(Brightness.dark),
      extensions: const <ThemeExtension<dynamic>>[
        ConfettiTheme(particleColors: defaultConfettiParticleColors),
      ],
    ),
  );

  /// Shared Material 3 component themes (list density, icon press, snackbars).
  ///
  /// Keeps feature widgets on tokens instead of one-off style copies.
  static ThemeData _withComponentThemes(ThemeData base) {
    final ColorScheme colors = base.colorScheme;
    final TextTheme text = base.textTheme;
    return base.copyWith(
      listTileTheme: ListTileThemeData(
        dense: true,
        minVerticalPadding: 8,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        iconColor: colors.onSurfaceVariant,
        titleTextStyle: text.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colors.onSurface,
        ),
        subtitleTextStyle: text.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colors.onSurfaceVariant,
          overlayColor: colors.primary.withValues(alpha: 0.12),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        actionTextColor: colors.inversePrimary,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.secondary,
      ),
    );
  }

  /// Text theme using Roboto with Comfortaa for display styles.
  static TextTheme createAppTextTheme(Brightness brightness) {
    final TextTheme robotoTheme = GoogleFonts.robotoTextTheme(
      ThemeData(brightness: brightness).textTheme,
    );
    final String? comfortaaFamily = GoogleFonts.comfortaa().fontFamily;
    TextStyle? withComfortaa(TextStyle? style) =>
        style?.copyWith(fontFamily: comfortaaFamily);
    return TextTheme(
      displayLarge: withComfortaa(robotoTheme.displayLarge),
      displayMedium: withComfortaa(robotoTheme.displayMedium),
      displaySmall: withComfortaa(robotoTheme.displaySmall),
      headlineLarge: robotoTheme.headlineLarge,
      headlineMedium: robotoTheme.headlineMedium,
      headlineSmall: robotoTheme.headlineSmall,
      titleLarge: robotoTheme.titleLarge,
      titleMedium: robotoTheme.titleMedium,
      titleSmall: robotoTheme.titleSmall,
      bodyLarge: robotoTheme.bodyLarge,
      bodyMedium: robotoTheme.bodyMedium,
      bodySmall: robotoTheme.bodySmall,
      labelLarge: robotoTheme.labelLarge,
      labelMedium: robotoTheme.labelMedium,
      labelSmall: robotoTheme.labelSmall,
    );
  }

  /// Arabic-optimized text theme.
  ///
  /// Uses bundled Cairo for all styles (no Comfortaa overrides).
  static TextTheme createArabicTextTheme(TextTheme baseTextTheme) =>
      baseTextTheme.apply(fontFamily: arabicFontFamily);
}
