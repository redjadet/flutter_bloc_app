import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

/// A shared layout for empty/error/status views with optional icon, title,
/// and action content.
class CommonStatusView extends StatelessWidget {
  const CommonStatusView({
    required this.message,
    super.key,
    this.title,
    this.icon,
    this.iconSize,
    this.iconColor,
    this.messageStyle,
    this.titleStyle,
    this.action,
    this.semanticsLabel,
    this.padding,
  });

  final String message;
  final String? title;
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;
  final TextStyle? messageStyle;
  final TextStyle? titleStyle;
  final Widget? action;
  final String? semanticsLabel;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final Widget content = Center(
      child: Padding(
        padding: padding ?? context.responsiveStatePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: iconSize,
                color: iconColor,
              ),
              SizedBox(height: context.responsiveGapL),
            ],
            if (title != null) ...[
              Text(
                title!,
                style: titleStyle ?? theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.responsiveGapM),
            ],
            Text(
              message,
              style: messageStyle ?? theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              SizedBox(height: context.responsiveGapL * 1.5),
              action!,
            ],
          ],
        ),
      ),
    );

    if (semanticsLabel == null) {
      return content;
    }

    return Semantics(label: semanticsLabel, child: content);
  }
}
