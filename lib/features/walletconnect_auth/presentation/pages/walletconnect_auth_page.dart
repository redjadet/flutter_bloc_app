import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/wallet_address.dart';
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
    return CommonPageLayout(
      title: context.l10n.walletconnectAuthTitle,
      body: TypeSafeBlocBuilder<WalletConnectAuthCubit, WalletConnectAuthState>(
        builder: (final context, final state) =>
            _WalletConnectAuthContent(state: state),
      ),
    );
  }
}

class _WalletConnectAuthContent extends StatelessWidget {
  const _WalletConnectAuthContent({required this.state});

  final WalletConnectAuthState state;

  @override
  Widget build(final BuildContext context) {
    final WalletConnectAuthCubit cubit = context
        .cubit<WalletConnectAuthCubit>();

    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: context.responsiveGapL),
          if (state.errorMessage case final msg?) ...<Widget>[
            _StatusBannerCard.error(
              message: msg,
              onDismiss: cubit.clearError,
            ),
            SizedBox(height: context.responsiveGapM),
          ],
          if (state.isLinked) ...<Widget>[
            _StatusBannerCard.success(
              message: context.l10n.walletLinked,
            ),
            SizedBox(height: context.responsiveGapM),
          ],
          if (state.linkedWalletAddress case final addr?) ...<Widget>[
            _LinkedWalletSection(
              address: addr,
              showRelinkButton: !state.isLoadingLinkedWallet,
              onRelink: cubit.relinkWalletToUser,
            ),
            SizedBox(height: context.responsiveGapL),
          ],
          if (state.linkedProfile case final profile?) ...<Widget>[
            _WalletProfileSection(profile: profile),
            SizedBox(height: context.responsiveGapL),
          ],
          if (state.unlinkedWalletAddress case final addr?) ...<Widget>[
            WalletAddressDisplay(address: addr),
            SizedBox(height: context.responsiveGapM),
          ],
          if (state.showConnectButton)
            ConnectWalletButton(onPressed: cubit.connectWallet),
          if (state.showLinkButton) ...<Widget>[
            PlatformAdaptive.outlinedButton(
              context: context,
              onPressed: cubit.linkWalletToUser,
              child: Text(context.l10n.linkToFirebase),
            ),
            SizedBox(height: context.responsiveGapM),
          ],
          if (state.showLoadingIndicator) const _LoadingSection(),
          if (state.isConnected) ...<Widget>[
            SizedBox(height: context.responsiveGapM),
            PlatformAdaptive.textButton(
              context: context,
              onPressed: state.isBusy ? null : cubit.disconnectWallet,
              child: Text(context.l10n.disconnectWallet),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBannerCard extends StatelessWidget {
  const _StatusBannerCard._({
    required this.message,
    required this.iconData,
    required this.backgroundColor,
    required this.foregroundColor,
    this.onDismiss,
  });

  const _StatusBannerCard.error({
    required final String message,
    required final VoidCallback onDismiss,
  }) : this._(
         message: message,
         iconData: Icons.error_outline,
         backgroundColor: null,
         foregroundColor: null,
         onDismiss: onDismiss,
       );

  const _StatusBannerCard.success({
    required final String message,
  }) : this._(
         message: message,
         iconData: Icons.check_circle_outline,
         backgroundColor: null,
         foregroundColor: null,
       );

  final String message;
  final IconData iconData;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final VoidCallback? onDismiss;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final double iconSize = math.min(context.responsiveIconSize, 28);
    final bool isDismissible = onDismiss != null;
    final bool isErrorBanner = iconData == Icons.error_outline;
    final Color resolvedBackgroundColor =
        backgroundColor ??
        (isErrorBanner ? colors.errorContainer : colors.primaryContainer);
    final Color resolvedForegroundColor =
        foregroundColor ??
        (isErrorBanner ? colors.onErrorContainer : colors.onPrimaryContainer);

    return CommonCard(
      color: resolvedBackgroundColor,
      elevation: 0,
      margin: EdgeInsets.zero,
      padding: context.responsiveCardPaddingInsets,
      child: Row(
        children: <Widget>[
          Icon(
            iconData,
            color: resolvedForegroundColor,
            size: iconSize,
          ),
          SizedBox(width: context.responsiveHorizontalGapM),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: resolvedForegroundColor,
              ),
              maxLines: isDismissible ? 5 : 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onDismiss case final dismiss?)
            IconButton(
              icon: Icon(
                Icons.close,
                color: resolvedForegroundColor,
                size: iconSize,
              ),
              onPressed: dismiss,
            ),
        ],
      ),
    );
  }
}

class _LinkedWalletSection extends StatelessWidget {
  const _LinkedWalletSection({
    required this.address,
    required this.showRelinkButton,
    required this.onRelink,
  });

  final WalletAddress address;
  final bool showRelinkButton;
  final VoidCallback onRelink;

  @override
  Widget build(final BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        WalletAddressDisplay(address: address),
        SizedBox(height: context.responsiveGapM),
        if (showRelinkButton)
          PlatformAdaptive.outlinedButton(
            context: context,
            onPressed: onRelink,
            child: Text(context.l10n.relinkToAccount),
          ),
      ],
    );
  }
}

class _LoadingSection extends StatelessWidget {
  const _LoadingSection();

  @override
  Widget build(final BuildContext context) {
    return Center(
      child: Padding(
        padding: context.responsiveCardPaddingInsets,
        child: const CommonLoadingWidget(),
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

    final dateText = switch (profile.lastClaim) {
      final d? => material.formatShortDate(d),
      _ => l10n.lastClaimNever,
    };

    return CommonCard(
      color: colors.surfaceContainerHighest,
      elevation: 0,
      margin: EdgeInsets.zero,
      padding: context.responsiveCardPaddingInsets,
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
          ),
          SizedBox(height: context.responsiveGapS),
          _ProfileRow(
            label: l10n.balanceOnChain,
            value: profile.balanceOnChain.toStringAsFixed(2),
          ),
          SizedBox(height: context.responsiveGapS),
          _ProfileRow(
            label: l10n.rewards,
            value: profile.rewards.toStringAsFixed(2),
          ),
          SizedBox(height: context.responsiveGapS),
          _ProfileRow(
            label: l10n.lastClaim,
            value: dateText,
          ),
          SizedBox(height: context.responsiveGapS),
          _ProfileRow(
            label: l10n.nfts,
            value: l10n.nftsCount(profile.nfts.length),
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
  });

  final String label;
  final String value;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
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

extension on WalletConnectAuthState {
  WalletAddress? get unlinkedWalletAddress => isLinked ? null : walletAddress;

  WalletUserProfile? get linkedProfile => isLinked ? userProfile : null;

  bool get showConnectButton => !isConnected && !isConnecting && !isLinked;

  bool get showLinkButton => isConnected && !isLinked && !isLinking;

  bool get isLoadingLinkedWallet => isLinked && status == ViewStatus.loading;

  bool get showLoadingIndicator =>
      isConnecting || isLinking || isLoadingLinkedWallet;

  bool get isBusy => isConnecting || isLinking;
}
