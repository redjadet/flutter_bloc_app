import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/igaming_demo/domain/demo_balance.dart';
import 'package:flutter_bloc_app/features/igaming_demo/domain/game_round_result.dart';
import 'package:flutter_bloc_app/features/igaming_demo/presentation/game_cubit.dart';
import 'package:flutter_bloc_app/features/igaming_demo/presentation/game_state.dart';
import 'package:flutter_bloc_app/features/igaming_demo/presentation/widgets/slot_machine_spinner.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/widgets/common_card.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/shared/widgets/type_safe_bloc_selector.dart';
import 'package:go_router/go_router.dart';

/// Stake options (in minor units) for the demo game.
const List<int> _stakeOptions = <int>[10, 50, 100, 500];

String _symbolLegendLabel(final AppLocalizations l10n, final String symbol) {
  switch (symbol) {
    case '7':
      return l10n.igamingDemoSymbol7;
    case '★':
      return l10n.igamingDemoSymbolStar;
    case '◆':
      return l10n.igamingDemoSymbolDiamond;
    case '●':
      return l10n.igamingDemoSymbolCircle;
    case '▲':
      return l10n.igamingDemoSymbolTriangle;
    case '♦':
      return l10n.igamingDemoSymbolGem;
    default:
      return symbol;
  }
}

/// Game page for one play-for-fun round: stake, spin, result.
class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.igamingDemoGameTitle,
      body: TypeSafeBlocBuilder<GameCubit, GameState>(
        builder: (final context, final state) {
          return state.when(
            idle: (final balance, final selectedStake) => _GameBody(
              balance: balance,
              selectedStake: selectedStake,
              isSpinning: false,
              result: null,
              targetReelSymbolIndices: const <int>[],
              onStakeSelected: (final amount) =>
                  context.cubit<GameCubit>().setStake(amount),
              onSpin: () => context.cubit<GameCubit>().playRound(),
              onPlayAgain: () => context.cubit<GameCubit>().playAgain(),
              onBackToLobby: () => context.go(AppRoutes.igamingDemoPath),
            ),
            placingBet: (final balance, final selectedStake) => _GameBody(
              balance: balance,
              selectedStake: selectedStake,
              isSpinning: false,
              result: null,
              targetReelSymbolIndices: const <int>[],
              onStakeSelected: (final amount) =>
                  context.cubit<GameCubit>().setStake(amount),
              onSpin: () => context.cubit<GameCubit>().playRound(),
              onPlayAgain: () => context.cubit<GameCubit>().playAgain(),
              onBackToLobby: () => context.go(AppRoutes.igamingDemoPath),
            ),
            spinning: (final balance, final bet, final targetIndices) =>
                _GameBody(
                  balance: DemoBalance(
                    amountUnits: (balance.amountUnits - bet).clamp(
                      0,
                      balance.amountUnits,
                    ),
                  ),
                  selectedStake: bet,
                  isSpinning: true,
                  result: null,
                  targetReelSymbolIndices: targetIndices,
                  onStakeSelected: (_) {},
                  onSpin: () {},
                  onPlayAgain: () => context.cubit<GameCubit>().playAgain(),
                  onBackToLobby: () => context.go(AppRoutes.igamingDemoPath),
                ),
            result:
                (
                  final roundResult,
                  final balance,
                  final selectedStake,
                  final targetIndices,
                ) => _GameBody(
                  balance: balance,
                  selectedStake: selectedStake,
                  isSpinning: false,
                  result: roundResult,
                  targetReelSymbolIndices: targetIndices,
                  onStakeSelected: (final amount) =>
                      context.cubit<GameCubit>().setStake(amount),
                  onSpin: () => context.cubit<GameCubit>().playRound(),
                  onPlayAgain: () => context.cubit<GameCubit>().playAgain(),
                  onBackToLobby: () => context.go(AppRoutes.igamingDemoPath),
                ),
            error: (final message) => CommonErrorView(
              message: message,
              onRetry: () => context.cubit<GameCubit>().loadBalance(),
            ),
          );
        },
      ),
    );
  }
}

class _GameBody extends StatelessWidget {
  const _GameBody({
    required this.balance,
    required this.selectedStake,
    required this.isSpinning,
    required this.result,
    required this.targetReelSymbolIndices,
    required this.onStakeSelected,
    required this.onSpin,
    required this.onPlayAgain,
    required this.onBackToLobby,
  });

  final DemoBalance balance;
  final int selectedStake;
  final bool isSpinning;
  final GameRoundResult? result;
  final List<int> targetReelSymbolIndices;
  final void Function(int) onStakeSelected;
  final VoidCallback onSpin;
  final VoidCallback onPlayAgain;
  final VoidCallback onBackToLobby;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: context.responsiveGapM),
          CommonCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: Text(
                    l10n.igamingDemoBalanceLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${balance.amountUnits}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  semanticsLabel:
                      '${l10n.igamingDemoBalanceLabel}: ${balance.amountUnits}',
                ),
              ],
            ),
          ),
          SizedBox(height: context.responsiveGapL),
          Text(
            l10n.igamingDemoStakeLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: context.responsiveGapS),
          Wrap(
            spacing: context.responsiveGapS,
            runSpacing: context.responsiveGapS,
            children: _stakeOptions.map((final amount) {
              final bool selected = selectedStake == amount;
              return ChoiceChip(
                label: Text('$amount'),
                selected: selected,
                onSelected: isSpinning ? null : (_) => onStakeSelected(amount),
              );
            }).toList(),
          ),
          SizedBox(height: context.responsiveGapL),
          Text(
            l10n.igamingDemoSymbolLegendTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: context.responsiveGapS),
          Text(
            l10n.igamingDemoSymbolWinHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: context.responsiveGapS),
          Wrap(
            spacing: context.responsiveGapM,
            runSpacing: context.responsiveGapS,
            children: kSlotReelSymbols.map((final symbol) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    symbol,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    semanticsLabel: _symbolLegendLabel(l10n, symbol),
                  ),
                  SizedBox(width: context.responsiveGapS),
                  Text(
                    _symbolLegendLabel(l10n, symbol),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              );
            }).toList(),
          ),
          SizedBox(height: context.responsiveGapL),
          if (isSpinning || result != null) ...<Widget>[
            CommonCard(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: context.responsiveGapM,
                ),
                child: SlotMachineSpinner(
                  duration: kSpinAnimationDuration,
                  staticProgress: isSpinning ? null : 1.0,
                  targetSymbolIndices: targetReelSymbolIndices.length == 3
                      ? targetReelSymbolIndices
                      : null,
                ),
              ),
            ),
            SizedBox(height: context.responsiveGapM),
          ],
          FilledButton(
            onPressed: isSpinning ? null : onSpin,
            child: Text(l10n.igamingDemoPlayButton),
          ),
          if (result != null) ...<Widget>[
            SizedBox(height: context.responsiveGapL),
            Builder(
              builder: (final _) {
                // check-ignore: unguarded_null_assertion - result is non-null
                final roundResult = result!;
                return CommonCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        roundResult.isWin
                            ? l10n.igamingDemoResultWin
                            : l10n.igamingDemoResultLoss,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: roundResult.isWin
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: context.responsiveGapS),
                      Text(
                        '${l10n.igamingDemoBalanceLabel}: '
                        '${balance.amountUnits}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: context.responsiveGapM),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: onPlayAgain,
                    child: Text(l10n.igamingDemoPlayAgain),
                  ),
                ),
                SizedBox(width: context.responsiveGapM),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onBackToLobby,
                    child: Text(l10n.igamingDemoBackToLobby),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
