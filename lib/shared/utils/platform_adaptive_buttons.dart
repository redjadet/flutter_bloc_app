import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

class PlatformAdaptiveButtons {
  const PlatformAdaptiveButtons._();

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
    if (PlatformAdaptive.isCupertino(context)) {
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

  static Widget textButton({
    required final BuildContext context,
    required final VoidCallback? onPressed,
    required final Widget child,
    final EdgeInsetsGeometry? padding,
    final Color? color,
    final Color? disabledColor,
    final ButtonStyle? materialStyle,
  }) {
    if (PlatformAdaptive.isCupertino(context)) {
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
    if (PlatformAdaptive.isCupertino(context)) {
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

  static Widget outlinedButton({
    required final BuildContext context,
    required final VoidCallback? onPressed,
    required final Widget child,
    final EdgeInsetsGeometry? padding,
    final Color? backgroundColor,
    final Color? foregroundColor,
    final Color? disabledColor,
    final BorderSide? side,
    final BorderRadius? borderRadius,
    final ButtonStyle? materialStyle,
  }) {
    if (PlatformAdaptive.isCupertino(context)) {
      final bool isDisabled = onPressed == null;
      final BorderSide resolvedSide =
          side ??
          BorderSide(
            color:
                foregroundColor ??
                (isDisabled
                    ? CupertinoColors.quaternaryLabel
                    : CupertinoColors.activeBlue),
          );
      final Color resolvedTextColor = isDisabled
          ? (disabledColor ?? CupertinoColors.quaternaryLabel)
          : (foregroundColor ?? CupertinoColors.activeBlue);
      final BorderRadius resolvedRadius =
          borderRadius ?? BorderRadius.circular(8);
      return DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: resolvedRadius,
          border: Border.fromBorderSide(resolvedSide),
        ),
        child: CupertinoButton(
          onPressed: onPressed,
          padding: padding,
          color: Colors.transparent,
          disabledColor: Colors.transparent,
          borderRadius: resolvedRadius,
          child: DefaultTextStyle(
            style: TextStyle(color: resolvedTextColor),
            child: child,
          ),
        ),
      );
    }
    return OutlinedButton(
      onPressed: onPressed,
      style:
          materialStyle ??
          OutlinedButton.styleFrom(
            padding: padding,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            disabledForegroundColor: disabledColor,
            side: side,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(8),
            ),
          ),
      child: child,
    );
  }

  static Widget dialogAction({
    required final BuildContext context,
    required final VoidCallback? onPressed,
    required final String label,
    final bool isDestructive = false,
  }) {
    if (PlatformAdaptive.isCupertino(context)) {
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
