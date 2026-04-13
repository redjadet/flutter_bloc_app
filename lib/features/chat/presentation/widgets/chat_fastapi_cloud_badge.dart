import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/design_system/app_styles.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:mix/mix.dart';

/// Shown when orchestration is hosted on FastAPI Cloud.
class ChatFastApiCloudBadge extends StatelessWidget {
  const ChatFastApiCloudBadge({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    return Semantics(
      label: l10n.chatFastApiCloudBadgeSemanticsLabel,
      child: Tooltip(
        message: l10n.chatFastApiCloudBadgeSemanticsLabel,
        child: ExcludeSemantics(
          child: Box(
            style: AppStyles.chip,
            child: Text(
              l10n.chatFastApiCloudBadgeLabel,
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
