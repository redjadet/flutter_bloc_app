import 'package:flutter/material.dart';

/// Helpers to keep platform-adaptive branching consistent across the app.
class PlatformAdaptive {
  const PlatformAdaptive._();

  static bool isCupertino(BuildContext context) =>
      isCupertinoFromTheme(Theme.of(context));

  static bool isCupertinoFromTheme(ThemeData theme) =>
      isCupertinoPlatform(theme.platform);

  static bool isCupertinoPlatform(TargetPlatform platform) =>
      platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
}
