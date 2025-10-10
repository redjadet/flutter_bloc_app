import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';

class GoogleMapsUnsupportedMessage extends StatelessWidget {
  const GoogleMapsUnsupportedMessage({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(UI.gapL),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

class GoogleMapsErrorMessage extends StatelessWidget {
  const GoogleMapsErrorMessage({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(UI.gapL),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      ),
    );
  }
}

class GoogleMapsMissingKeyMessage extends StatelessWidget {
  const GoogleMapsMissingKeyMessage({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(UI.gapL),
        child: Card(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: UI.cardPadH,
              vertical: UI.cardPadV,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                SizedBox(height: UI.gapS),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
