part of 'supabase_auth_page.dart';

/// Shown when Supabase is not configured.
class SupabaseAuthNotConfiguredCard extends StatelessWidget {
  const SupabaseAuthNotConfiguredCard({
    required this.theme,
    required this.colors,
    required this.l10n,
    super.key,
  });

  final ThemeData theme;
  final ColorScheme colors;
  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) {
    return CommonCard(
      color: colors.surfaceContainerHighest,
      elevation: 0,
      margin: EdgeInsets.zero,
      padding: context.responsiveCardPaddingInsets,
      child: Text(
        l10n.supabaseAuthNotConfigured,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Error message card with dismiss and optional child content below.
class SupabaseAuthErrorSection extends StatelessWidget {
  const SupabaseAuthErrorSection({
    required this.message,
    required this.theme,
    required this.colors,
    required this.onDismiss,
    required this.child,
    super.key,
  });

  final String message;
  final ThemeData theme;
  final ColorScheme colors;
  final VoidCallback onDismiss;
  final Widget child;

  @override
  Widget build(final BuildContext context) {
    final double iconSize = math.min(context.responsiveIconSize, 28);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CommonCard(
          color: colors.errorContainer,
          elevation: 0,
          margin: EdgeInsets.zero,
          padding: context.responsiveCardPaddingInsets,
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: colors.onErrorContainer,
                size: iconSize,
              ),
              SizedBox(width: context.responsiveHorizontalGapM),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onErrorContainer,
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: colors.onErrorContainer,
                  size: iconSize,
                ),
                onPressed: onDismiss,
              ),
            ],
          ),
        ),
        SizedBox(height: context.responsiveGapM),
        child,
      ],
    );
  }
}
