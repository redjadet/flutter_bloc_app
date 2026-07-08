import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

class GoogleMapsUnsupportedMessage extends StatelessWidget {
  const GoogleMapsUnsupportedMessage({required this.message, super.key});

  final String message;

  @override
  Widget build(final BuildContext context) => AppMessage(message: message);
}

class GoogleMapsErrorMessage extends StatelessWidget {
  const GoogleMapsErrorMessage({
    required this.message,
    this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return AppMessage(
      message: message,
      isError: true,
      actions: onRetry == null
          ? null
          : <Widget>[
              PlatformAdaptive.textButton(
                context: context,
                onPressed: onRetry,
                child: Text(l10n.retryButtonLabel),
              ),
            ],
    );
  }
}

class GoogleMapsMissingKeyMessage extends StatelessWidget {
  const GoogleMapsMissingKeyMessage({
    required this.title,
    required this.description,
    super.key,
  });

  final String title;
  final String description;

  @override
  Widget build(final BuildContext context) =>
      AppMessage(title: title, message: description, isError: true);
}
