import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/widgets/app_message.dart';

class GoogleMapsUnsupportedMessage extends StatelessWidget {
  const GoogleMapsUnsupportedMessage({required this.message, super.key});

  final String message;

  @override
  Widget build(final BuildContext context) => AppMessage(message: message);
}

class GoogleMapsErrorMessage extends StatelessWidget {
  const GoogleMapsErrorMessage({required this.message, super.key});

  final String message;

  @override
  Widget build(final BuildContext context) =>
      AppMessage(message: message, isError: true);
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
