import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_status_view.dart';

class ChatHistoryEmptyState extends StatelessWidget {
  const ChatHistoryEmptyState({required this.l10n, super.key});

  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return CommonStatusView(
      message: l10n.chatHistoryEmpty,
      messageStyle: theme.textTheme.bodyMedium,
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveHorizontalGapL,
      ),
    );
  }
}
