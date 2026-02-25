import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/wallet_address.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_bloc_app/shared/widgets/common_card.dart';

/// Widget displaying a wallet address in a truncated format.
/// Uses [CommonCard] for consistent shape and padding with outline border.
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

    return CommonCard(
      color: colors.surfaceContainerHighest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UI.radiusM),
        side: BorderSide(color: colors.outline),
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
