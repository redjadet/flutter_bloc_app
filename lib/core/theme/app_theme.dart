import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/constants/constants.dart';
import 'package:flutter_bloc_app/core/theme/theme_extensions.dart';
import 'package:google_fonts/google_fonts.dart';

/// Default decorative particle colors (confetti, etc.); not UI theme colors.
/// Use for [ConfettiTheme.particleColors] and as fallback when extension is null.
const List<Color> defaultConfettiParticleColors = [
  Colors.green,
  Colors.blue,
  Colors.pink,
  Colors.orange,
  Colors.purple,
];

/// Application theme factory.
///
/// Single place for [ThemeData], light/dark [ColorScheme], and [TextTheme].
/// Used by AppConfig when building MaterialApp.
class AppTheme {
  AppTheme._();

  /// Light theme for the app.
  static ThemeData lightTheme() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppConstants.primarySeedColor),
    textTheme: createAppTextTheme(Brightness.light),
    extensions: const <ThemeExtension<dynamic>>[
      ConfettiTheme(particleColors: defaultConfettiParticleColors),
    ],
  );

  /// Dark theme for the app.
  static ThemeData darkTheme() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppConstants.primarySeedColor,
      brightness: Brightness.dark,
    ),
    textTheme: createAppTextTheme(Brightness.dark),
    extensions: const <ThemeExtension<dynamic>>[
      ConfettiTheme(particleColors: defaultConfettiParticleColors),
    ],
  );

  /// Text theme using Roboto with Comfortaa for display styles.
  static TextTheme createAppTextTheme(final Brightness brightness) {
    final ThemeData baseTheme = ThemeData(brightness: brightness);
    final TextTheme robotoTheme = GoogleFonts.robotoTextTheme(
      baseTheme.textTheme,
    );
    final String? comfortaaFamily = GoogleFonts.comfortaa().fontFamily;
    TextStyle? withComfortaa(final TextStyle? style) =>
        style?.copyWith(fontFamily: comfortaaFamily);
    return robotoTheme.copyWith(
      displayLarge: withComfortaa(robotoTheme.displayLarge),
      displayMedium: withComfortaa(robotoTheme.displayMedium),
      displaySmall: withComfortaa(robotoTheme.displaySmall),
    );
  }
}
