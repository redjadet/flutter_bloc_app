import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

/// Helper classes for CounterPageAppBar overflow menu items.
enum OverflowAction {
  charts,
  graphql,
  chat,
  genuiDemo,
  googleMaps,
  whiteboard,
  markdownEditor,
  todo,
}

/// Represents an item in the overflow menu.
class OverflowItem {
  const OverflowItem({
    required this.action,
    required this.routeName,
    required this.labelBuilder,
  });

  final OverflowAction action;
  final String routeName;
  final String Function(AppLocalizations l10n) labelBuilder;
}

/// Cupertino-style icon button for the app bar.
class CupertinoIconButton extends StatelessWidget {
  const CupertinoIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    super.key,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(final BuildContext context) => Tooltip(
    message: tooltip,
    child: CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Icon(icon, size: 22),
    ),
  );
}
