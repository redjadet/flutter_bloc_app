import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';

class AppMessage extends StatelessWidget {
  const AppMessage({
    super.key,
    required this.message,
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
  Widget build(BuildContext context) {
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
        padding: EdgeInsets.all(UI.gapL),
        child: Card(
          color: backgroundColor,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: UI.cardPadH,
              vertical: UI.cardPadV,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, size: UI.iconL * 2, color: textColor),
                  SizedBox(height: UI.gapM),
                ],
                if (title != null) ...<Widget>[
                  Text(
                    title!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: UI.gapS),
                ],
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
                  textAlign: TextAlign.center,
                ),
                if (actions != null && actions!.isNotEmpty) ...<Widget>[
                  SizedBox(height: UI.gapM),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: UI.gapM,
                    runSpacing: UI.gapS,
                    children: actions!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
