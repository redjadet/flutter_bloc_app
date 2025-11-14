import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

class ChatHistoryEmptyState extends StatelessWidget {
  const ChatHistoryEmptyState({required this.l10n, super.key});

  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveHorizontalGapL,
        ),
        child: Text(
          l10n.chatHistoryEmpty,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
