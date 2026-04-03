import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/design_system/app_styles.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:mix/mix.dart';

/// Shown when there is no network route; transport chip is hidden in this state.
class ChatOfflineBadge extends StatelessWidget {
  const ChatOfflineBadge({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    return Semantics(
      label: l10n.chatOfflineBadgeSemanticsLabel,
      child: Tooltip(
        message: l10n.chatOfflineBadgeSemanticsLabel,
        child: ExcludeSemantics(
          child: Box(
            style: AppStyles.chip,
            child: Text(
              l10n.chatOfflineBadgeLabel,
              style: theme.textTheme.labelMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
