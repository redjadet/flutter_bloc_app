import 'package:flutter/material.dart';

/// Visual tokens for the realtime market demo.
///
/// [bidAccent] reads [ColorScheme.tertiary]; the realtime market route scopes
/// tertiary to [kRealtimeMarketBidGreen] at the page root.
abstract final class RealtimeMarketUiTokens {
  static Color bidAccent(final ColorScheme scheme) => scheme.tertiary;

  static Color askAccent(final ColorScheme scheme) => scheme.error;
}

/// Success green used for buy/bid accents on the realtime market route only.
const Color kRealtimeMarketBidGreen = Color(0xFF4CAF50);
