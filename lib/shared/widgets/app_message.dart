import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/shared.dart';

class AppMessage extends StatelessWidget {
  const AppMessage({
    required this.message,
    super.key,
    this.title,
    this.icon,
    this.isError = false,
    this.actions,
  });

  final String message;
  final String? title;
  final IconData? icon;
  final bool isError;
  final List<Widget>? actions;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final Color backgroundColor = isError
        ? colors.errorContainer
        : colors.surfaceContainerHighest;
    final Color textColor = isError
        ? colors.onErrorContainer
        : colors.onSurface;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.responsiveGapL),
        child: CommonCard(
          color: backgroundColor,
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveCardPadding,
            vertical: context.responsiveGapL,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(
                  icon,
                  size: context.responsiveIconSize * 2,
                  color: textColor,
                ),
                SizedBox(height: context.responsiveGapM),
              ],
              if (title != null) ...<Widget>[
                Text(
                  title!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.responsiveGapS),
              ],
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
                textAlign: TextAlign.center,
              ),
              if (actions != null && actions!.isNotEmpty) ...<Widget>[
                SizedBox(height: context.responsiveGapM),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: context.responsiveGapM,
                  runSpacing: context.responsiveGapS,
                  children: actions!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
