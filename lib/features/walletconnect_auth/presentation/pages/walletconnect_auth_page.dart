import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      body: BlocBuilder<WalletConnectAuthCubit, WalletConnectAuthState>(
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
                        onPressed: () =>
                            context.cubit<WalletConnectAuthCubit>().clearError(),
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
                SizedBox(height: context.responsiveGapL),
              ],

              // Connected wallet address display
              if (state.walletAddress != null && !state.isLinked) ...[
                WalletAddressDisplay(address: state.walletAddress!),
                SizedBox(height: context.responsiveGapM),
              ],

              // Connect Wallet button
              if (!state.isConnected && !state.isConnecting) ...[
                ConnectWalletButton(
                  onPressed: () =>
                      context.cubit<WalletConnectAuthCubit>().connectWallet(),
                ),
              ],

              // Link to Firebase button
              if (state.isConnected && !state.isLinked && !state.isLinking) ...[
                PlatformAdaptive.outlinedButton(
                  context: context,
                  onPressed: () =>
                      context.cubit<WalletConnectAuthCubit>().linkWalletToUser(),
                  child: Text(l10n.linkToFirebase),
                ),
                SizedBox(height: context.responsiveGapM),
              ],

              // Loading indicator
              if (state.isConnecting || state.isLinking) ...[
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
