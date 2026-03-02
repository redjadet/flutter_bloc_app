import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/igaming_demo/domain/demo_balance.dart';
import 'package:flutter_bloc_app/features/igaming_demo/presentation/lobby_cubit.dart';
import 'package:flutter_bloc_app/features/igaming_demo/presentation/lobby_state.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/widgets/common_card.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/shared/widgets/type_safe_bloc_selector.dart';
import 'package:go_router/go_router.dart';

/// Lobby page for the iGaming demo: shows virtual balance and entry to game.
class LobbyPage extends StatelessWidget {
  const LobbyPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.igamingDemoLobbyTitle,
      body: TypeSafeBlocBuilder<LobbyCubit, LobbyState>(
        builder: (final context, final state) {
          return state.when(
            initial: () => const _LoadingBody(),
            loading: () => const _LoadingBody(),
            ready: (final balance) => _ReadyBody(
              balance: balance,
              onPlayGame: () => context.go(AppRoutes.igamingDemoGamePath),
            ),
            error: (final message) => CommonErrorView(
              message: message,
              onRetry: () => context.cubit<LobbyCubit>().loadBalance(),
            ),
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
