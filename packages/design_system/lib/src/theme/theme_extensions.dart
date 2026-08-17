import 'package:material_ui/material_ui.dart';

/// Theme extension for decorative (non-functional) UI elements such as
/// confetti particles and sparkles. These are not part of the main
/// color scheme and are not used for contrast-sensitive UI.
@immutable
class ConfettiTheme extends ThemeExtension<ConfettiTheme> {
  const ConfettiTheme({required this.particleColors});

  final List<Color> particleColors;

  @override
  ConfettiTheme copyWith({List<Color>? particleColors}) =>
      ConfettiTheme(particleColors: particleColors ?? this.particleColors);

  @override
  ConfettiTheme lerp(ConfettiTheme? other, double t) => this;
}
