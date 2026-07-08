import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/igaming_demo/domain/demo_balance.dart';
import 'package:flutter_bloc_app/features/igaming_demo/presentation/cubit/lobby_cubit.dart';
import 'package:flutter_bloc_app/features/igaming_demo/presentation/cubit/lobby_state.dart';
import 'package:go_router/go_router.dart';

/// Lobby page for the iGaming demo: shows virtual balance and entry to game.
class LobbyPage extends StatelessWidget {
  const LobbyPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.igamingDemoLobbyTitle,
      body: Builder(
        builder: (final context) {
          final viewState = context
              .selectState<
                LobbyCubit,
                LobbyState,
                ({bool isLoading, DemoBalance? balance, String? errorMessage})
              >(
                selector: (final state) => state.when(
                  initial: () => (
                    isLoading: true,
                    balance: null,
                    errorMessage: null,
                  ),
                  loading: () => (
                    isLoading: true,
                    balance: null,
                    errorMessage: null,
                  ),
                  ready: (final balance) => (
                    isLoading: false,
                    balance: balance,
                    errorMessage: null,
                  ),
                  error: (final message) => (
                    isLoading: false,
                    balance: null,
                    errorMessage: message,
                  ),
                ),
              );

          if (viewState.isLoading) {
            return const _LoadingBody();
          }

          if (viewState.errorMessage case final String message?) {
            return CommonErrorView(
              message: message,
              onRetry: () => context.cubit<LobbyCubit>().loadBalance(),
            );
          }

          final balance = viewState.balance;
          if (balance == null) {
            return const _LoadingBody();
          }

          return _ReadyBody(
            balance: balance,
            onPlayGame: () => context.go(AppRoutes.igamingDemoGamePath),
          );
        },
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(final BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ReadyBody extends StatelessWidget {
  const _ReadyBody({
    required this.balance,
    required this.onPlayGame,
  });

  final DemoBalance balance;
  final VoidCallback onPlayGame;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: context.responsiveGapL),
          CommonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  l10n.igamingDemoBalanceLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: context.responsiveGapS),
                Text(
                  '${balance.amountUnits}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  semanticsLabel:
                      '${l10n.igamingDemoBalanceLabel}: '
                      '${balance.amountUnits}',
                ),
              ],
            ),
          ),
          SizedBox(height: context.responsiveGapL),
          FilledButton(
            onPressed: onPlayGame,
            child: Text(l10n.igamingDemoPlayGame),
          ),
        ],
      ),
    );
  }
}
