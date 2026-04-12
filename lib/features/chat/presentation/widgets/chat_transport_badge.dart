import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/shared/design_system/app_styles.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:mix/mix.dart';

/// Online-only chip: which remote path chat used or would use for the badge row.
class ChatTransportBadge extends StatelessWidget {
  const ChatTransportBadge({
    required this.transport,
    this.renderDemoStrict = false,
    super.key,
  });

  final ChatInferenceTransport transport;

  /// When true with [ChatInferenceTransport.renderOrchestration], shows strict-mode copy under the chip.
  final bool renderDemoStrict;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final String label = switch (transport) {
      ChatInferenceTransport.supabase => l10n.chatTransportSupabase,
      ChatInferenceTransport.direct => l10n.chatTransportDirect,
      ChatInferenceTransport.renderOrchestration => l10n.chatTransportRenderOrchestration,
    };
    final String semanticsLabel = switch (transport) {
      ChatInferenceTransport.supabase =>
        l10n.chatTransportSupabaseSemanticsLabel,
      ChatInferenceTransport.direct => l10n.chatTransportDirectSemanticsLabel,
      ChatInferenceTransport.renderOrchestration =>
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

    if (transport == ChatInferenceTransport.renderOrchestration && renderDemoStrict) {
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
