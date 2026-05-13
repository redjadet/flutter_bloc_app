import 'package:flutter/material.dart';

/// Visual tokens for the realtime market demo (buy green matches app Mix
/// success token registered in `mix_app_theme.dart`).
abstract final class RealtimeMarketUiTokens {
  static const Color bidAccent = Color(0xFF4CAF50);

  static Color askAccent(final ColorScheme scheme) => scheme.error;
}
