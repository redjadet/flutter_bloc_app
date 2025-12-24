import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Helpers to keep platform-adaptive branching consistent across the app.
class PlatformAdaptive {
  const PlatformAdaptive._();

  static bool isCupertino(final BuildContext context) =>
      isCupertinoFromTheme(Theme.of(context));

  static bool isCupertinoFromTheme(final ThemeData theme) =>
      isCupertinoPlatform(theme.platform);

  static bool isCupertinoPlatform(final TargetPlatform platform) =>
      platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

  /// Returns a platform-adaptive button widget
  /// Uses CupertinoButton on iOS/macOS, Material button elsewhere
  static Widget button({
    required final BuildContext context,
    required final VoidCallback? onPressed,
    required final Widget child,
    final EdgeInsetsGeometry? padding,
    final Color? color,
    final Color? disabledColor,
    final double? minSize,
    final double? pressedOpacity,
    final BorderRadius? borderRadius,
    final ButtonStyle? materialStyle,
  }) {
    if (isCupertino(context)) {
      return CupertinoButton(
        onPressed: onPressed,
        padding: padding,
        color: color ?? CupertinoColors.activeBlue,
        disabledColor: disabledColor ?? CupertinoColors.quaternaryLabel,
        minimumSize: minSize != null ? Size(minSize, minSize) : null,
        pressedOpacity: pressedOpacity,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        child: child,
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      style:
          materialStyle ??
          ElevatedButton.styleFrom(
            padding: padding,
            backgroundColor: color,
            disabledBackgroundColor: disabledColor,
            minimumSize: minSize != null ? Size(minSize, minSize) : null,
          ),
      child: child,
    );
  }

  /// Returns a platform-adaptive text button widget
  static Widget textButton({
    required final BuildContext context,
    required final VoidCallback? onPressed,
    required final Widget child,
    final EdgeInsetsGeometry? padding,
    final Color? color,
    final Color? disabledColor,
    final ButtonStyle? materialStyle,
  }) {
    if (isCupertino(context)) {
      return CupertinoButton(
        onPressed: onPressed,
        padding: padding,
        color: Colors.transparent,
        disabledColor: disabledColor ?? CupertinoColors.quaternaryLabel,
        child: DefaultTextStyle(
          style: TextStyle(
            color: onPressed == null
                ? (disabledColor ?? CupertinoColors.quaternaryLabel)
                : (color ?? CupertinoColors.activeBlue),
          ),
          child: child,
        ),
      );
    }
    return TextButton(
      onPressed: onPressed,
      style:
          materialStyle ??
          TextButton.styleFrom(
            padding: padding,
            foregroundColor: color,
            disabledForegroundColor: disabledColor,
          ),
      child: child,
    );
  }

  /// Returns a platform-adaptive filled button widget
  static Widget filledButton({
    required final BuildContext context,
    required final VoidCallback? onPressed,
    required final Widget child,
    final Key? key,
    final EdgeInsetsGeometry? padding,
    final Color? color,
    final Color? disabledColor,
    final ButtonStyle? materialStyle,
  }) {
    if (isCupertino(context)) {
      return CupertinoButton.filled(
        key: key,
        onPressed: onPressed,
        padding: padding,
        disabledColor: disabledColor ?? CupertinoColors.quaternaryLabel,
        child: child,
      );
    }
    return FilledButton(
      key: key,
      onPressed: onPressed,
      style:
          materialStyle ??
          FilledButton.styleFrom(
            padding: padding,
            backgroundColor: color,
            disabledBackgroundColor: disabledColor,
          ),
      child: child,
    );
  }

  /// Returns a platform-adaptive dialog action button
  static Widget dialogAction({
    required final BuildContext context,
    required final VoidCallback? onPressed,
    required final String label,
    final bool isDestructive = false,
  }) {
    if (isCupertino(context)) {
      return CupertinoDialogAction(
        onPressed: onPressed,
        isDestructiveAction: isDestructive,
        child: Text(label),
      );
    }
    return TextButton(
      onPressed: onPressed,
      style: isDestructive
          ? TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            )
          : null,
      child: Text(label),
    );
  }
}
