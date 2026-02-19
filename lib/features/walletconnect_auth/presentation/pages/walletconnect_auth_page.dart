import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/wallet_user_profile.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/presentation/cubit/walletconnect_auth_cubit.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/presentation/cubit/walletconnect_auth_state.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/presentation/widgets/connect_wallet_button.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/presentation/widgets/wallet_address_display.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

/// Page for WalletConnect authentication demo.
class WalletConnectAuthPage extends StatelessWidget {
  const WalletConnectAuthPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return CommonPageLayout(
      title: l10n.walletconnectAuthTitle,
      body: TypeSafeBlocBuilder<WalletConnectAuthCubit, WalletConnectAuthState>(
        builder: (final context, final state) => SingleChildScrollView(
          padding: context.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: context.responsiveGapL),

              // Error message
              if (state.errorMessage != null) ...[
                Container(
                  padding: context.responsiveCardPaddingInsets,
                  decoration: BoxDecoration(
                    color: colors.errorContainer,
                    borderRadius: BorderRadius.circular(
                      context.responsiveCardRadius,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: colors.onErrorContainer,
                        size: context.responsiveIconSize,
                      ),
                      SizedBox(width: context.responsiveHorizontalGapM),
                      Expanded(
                        child: Text(
                          state.errorMessage!,
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
                          size: context.responsiveIconSize,
                        ),
                        onPressed: () => context
                            .cubit<WalletConnectAuthCubit>()
                            .clearError(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.responsiveGapM),
              ],

              // Success message
              if (state.isLinked) ...[
                Container(
                  padding: context.responsiveCardPaddingInsets,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(
                      context.responsiveCardRadius,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: colors.onPrimaryContainer,
                        size: context.responsiveIconSize,
                      ),
                      SizedBox(width: context.responsiveHorizontalGapM),
                      Expanded(
                        child: Text(
                          l10n.walletLinked,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onPrimaryContainer,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.responsiveGapM),
              ],

              // Linked wallet address display
              if (state.linkedWalletAddress != null) ...[
                WalletAddressDisplay(address: state.linkedWalletAddress!),
                SizedBox(height: context.responsiveGapM),
                // Re-link to account (refresh Firestore profile, etc.)
                if (state.status != ViewStatus.loading)
                  PlatformAdaptive.outlinedButton(
                    context: context,
                    onPressed: () => context
                        .cubit<WalletConnectAuthCubit>()
                        .relinkWalletToUser(),
                    child: Text(l10n.relinkToAccount),
                  ),
                SizedBox(height: context.responsiveGapL),
              ],

              // User profile (balance, rewards, NFTs) when linked
              if (state.isLinked && state.userProfile != null) ...[
                _WalletProfileSection(profile: state.userProfile!),
                SizedBox(height: context.responsiveGapL),
              ],

              // Connected wallet address display
              if (state.walletAddress != null && !state.isLinked) ...[
                WalletAddressDisplay(address: state.walletAddress!),
                SizedBox(height: context.responsiveGapM),
              ],

              // Connect Wallet button (hidden when already connected or linked)
              if (!state.isConnected &&
                  !state.isConnecting &&
                  !state.isLinked) ...[
                ConnectWalletButton(
                  onPressed: () =>
                      context.cubit<WalletConnectAuthCubit>().connectWallet(),
                ),
              ],

              // Link to Firebase button
              if (state.isConnected && !state.isLinked && !state.isLinking) ...[
                PlatformAdaptive.outlinedButton(
                  context: context,
                  onPressed: () => context
                      .cubit<WalletConnectAuthCubit>()
                      .linkWalletToUser(),
                  child: Text(l10n.linkToFirebase),
                ),
                SizedBox(height: context.responsiveGapM),
              ],

              // Loading indicator (connecting, linking, or re-linking)
              if (state.isConnecting ||
                  state.isLinking ||
                  (state.isLinked && state.status == ViewStatus.loading)) ...[
                Center(
                  child: Padding(
                    padding: context.responsiveCardPaddingInsets,
                    child: const CommonLoadingWidget(),
                  ),
                ),
              ],

              // Disconnect button
              if (state.isConnected) ...[
                SizedBox(height: context.responsiveGapM),
                PlatformAdaptive.textButton(
                  context: context,
                  onPressed: state.isConnecting || state.isLinking
                      ? null
                      : () => context
                            .cubit<WalletConnectAuthCubit>()
                            .disconnectWallet(),
                  child: Text(l10n.disconnectWallet),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Displays wallet user profile (balance, rewards, last claim, NFTs) on the connect wallet screen.
class _WalletProfileSection extends StatelessWidget {
  const _WalletProfileSection({required this.profile});

  final WalletUserProfile profile;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;
    final material = MaterialLocalizations.of(context);

    final dateText = profile.lastClaim != null
        ? material.formatShortDate(profile.lastClaim!)
        : l10n.lastClaimNever;

    return Container(
      padding: context.responsiveCardPaddingInsets,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(context.responsiveCardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.walletProfileSection,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.responsiveGapM),
          _ProfileRow(
            label: l10n.balanceOffChain,
            value: profile.balanceOffChain.toStringAsFixed(2),
            theme: theme,
            colors: colors,
          ),
          SizedBox(height: context.responsiveGapS),
          _ProfileRow(
            label: l10n.balanceOnChain,
            value: profile.balanceOnChain.toStringAsFixed(2),
            theme: theme,
            colors: colors,
          ),
          SizedBox(height: context.responsiveGapS),
          _ProfileRow(
            label: l10n.rewards,
            value: profile.rewards.toStringAsFixed(2),
            theme: theme,
            colors: colors,
          ),
          SizedBox(height: context.responsiveGapS),
          _ProfileRow(
            label: l10n.lastClaim,
            value: dateText,
            theme: theme,
            colors: colors,
          ),
          SizedBox(height: context.responsiveGapS),
          _ProfileRow(
            label: l10n.nfts,
            value: l10n.nftsCount(profile.nfts.length),
            theme: theme,
            colors: colors,
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.label,
    required this.value,
    required this.theme,
    required this.colors,
  });

  final String label;
  final String value;
  final ThemeData theme;
  final ColorScheme colors;

  @override
  Widget build(final BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        if (value.isNotEmpty)
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}
