import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/wallet_address.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

/// Widget displaying a wallet address in a truncated format.
class WalletAddressDisplay extends StatelessWidget {
  const WalletAddressDisplay({
    required this.address,
    super.key,
  });

  final WalletAddress address;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: context.responsiveCardPaddingInsets,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(context.responsiveCardRadius),
        border: Border.all(
          color: colors.outline,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet,
            color: colors.primary,
            size: context.responsiveIconSize,
          ),
          SizedBox(width: context.responsiveHorizontalGapM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.walletAddress,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: context.responsiveGapXS),
                Text(
                  address.truncated,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.onSurface,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
