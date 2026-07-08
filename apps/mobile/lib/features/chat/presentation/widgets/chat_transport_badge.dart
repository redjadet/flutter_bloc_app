import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:mix/mix.dart';

/// Online-only chip: which remote path chat used or would use for the badge row.
class ChatTransportBadge extends StatelessWidget {
  const ChatTransportBadge({
    required this.transport,
    this.renderDemoStrict = false,
    super.key,
  });

  final ChatRemotePath transport;

  /// When true with [ChatRemotePath.renderOrchestration], shows strict-mode copy under the chip.
  final bool renderDemoStrict;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final String label = switch (transport) {
      ChatRemotePath.edgeProxy => l10n.chatTransportSupabase,
      ChatRemotePath.directApi => l10n.chatTransportDirect,
      ChatRemotePath.renderOrchestration =>
        l10n.chatTransportRenderOrchestration,
    };
    final String semanticsLabel = switch (transport) {
      ChatRemotePath.edgeProxy => l10n.chatTransportSupabaseSemanticsLabel,
      ChatRemotePath.directApi => l10n.chatTransportDirectSemanticsLabel,
      ChatRemotePath.renderOrchestration =>
        l10n.chatTransportRenderOrchestrationSemanticsLabel,
    };
    final ThemeData theme = Theme.of(context);
    final Widget chipCore = ExcludeSemantics(
      child: Box(
        style: AppStyles.chip,
        child: Text(
          label,
          style: theme.textTheme.labelMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    if (transport == ChatRemotePath.renderOrchestration && renderDemoStrict) {
      final String strictLine = l10n.chatRenderStrictMode;
      return Semantics(
        label: '$semanticsLabel. $strictLine',
        child: Tooltip(
          message: '$semanticsLabel\n$strictLine',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              chipCore,
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  strictLine,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Semantics(
      label: semanticsLabel,
      child: Tooltip(
        message: semanticsLabel,
        child: chipCore,
      ),
    );
  }
}
