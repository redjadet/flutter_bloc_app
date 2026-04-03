import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/shared/design_system/app_styles.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:mix/mix.dart';

/// Online-only chip: which remote path chat used or would use for the badge row.
class ChatTransportBadge extends StatelessWidget {
  const ChatTransportBadge({required this.transport, super.key});

  final ChatInferenceTransport transport;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final String label = switch (transport) {
      ChatInferenceTransport.supabase => l10n.chatTransportSupabase,
      ChatInferenceTransport.direct => l10n.chatTransportDirect,
    };
    final String semanticsLabel = switch (transport) {
      ChatInferenceTransport.supabase =>
        l10n.chatTransportSupabaseSemanticsLabel,
      ChatInferenceTransport.direct => l10n.chatTransportDirectSemanticsLabel,
    };
    final ThemeData theme = Theme.of(context);
    return Semantics(
      label: semanticsLabel,
      child: Tooltip(
        message: semanticsLabel,
        child: ExcludeSemantics(
          child: Box(
            style: AppStyles.chip,
            child: Text(
              label,
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
