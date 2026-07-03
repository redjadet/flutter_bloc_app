part of 'game_page.dart';

class _GameScaffold extends StatelessWidget {
  const _GameScaffold();

  @override
  Widget build(final BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: context.responsiveGapM),
          const _GameBalanceCard(),
          SizedBox(height: context.responsiveGapL),
          const _StakeSection(),
          SizedBox(height: context.responsiveGapL),
          const _GameLegendSection(),
          SizedBox(height: context.responsiveGapL),
          const _SpinDisplaySection(),
          const _PrimaryActionSection(),
          const _ResultSummarySection(),
        ],
      ),
    );
  }
}

class _GameBalanceCard extends StatelessWidget {
  const _GameBalanceCard();

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final balance = context.selectState<GameCubit, GameState, DemoBalance?>(
      selector: _displayBalance,
    );

    if (balance == null) {
      return const SizedBox.shrink();
    }

    return CommonCard(
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
    );
  }
}

class _StakeSection extends StatelessWidget {
  const _StakeSection();

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cubit = context.cubit<GameCubit>();
    final stakeState = context
        .selectState<
          GameCubit,
          GameState,
          ({int? selectedStake, bool isSpinning})
        >(
          selector: (final state) => (
            selectedStake: state.selectedStakeOrNull,
            isSpinning: _isSpinning(state),
          ),
        );

    final selectedStake = stakeState.selectedStake;
    if (selectedStake == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
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
          children: _stakeOptions
              .map((final amount) {
                final bool selected = selectedStake == amount;
                return ChoiceChip(
                  label: Text('$amount'),
                  selected: selected,
                  onSelected: stakeState.isSpinning
                      ? null
                      : (_) => cubit.setStake(amount),
                );
              })
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _GameLegendSection extends StatelessWidget {
  const _GameLegendSection();

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
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
          children: kSlotReelSymbols
              .map((final symbol) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    buildSlotSymbolWidget(
                      symbol,
                      textStyle: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: context.responsiveGapS),
                    Text(
                      _symbolLegendLabel(l10n, symbol),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                );
              })
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _SpinDisplaySection extends StatelessWidget {
  const _SpinDisplaySection();

  @override
  Widget build(final BuildContext context) {
    final spinState = context
        .selectState<
          GameCubit,
          GameState,
          ({
            bool isSpinning,
            GameRoundResult? result,
            List<int> targetReelSymbolIndices,
          })
        >(
          selector: (final state) => (
            isSpinning: _isSpinning(state),
            result: _roundResult(state),
            targetReelSymbolIndices: state.targetReelSymbolIndicesOrEmpty,
          ),
        );

    if (!spinState.isSpinning && spinState.result == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: context.responsiveGapM),
      child: CommonCard(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: context.responsiveGapM),
          child: SlotMachineSpinner(
            duration: kSpinAnimationDuration,
            staticProgress: spinState.isSpinning ? null : 1.0,
            targetSymbolIndices: spinState.targetReelSymbolIndices.length == 3
                ? spinState.targetReelSymbolIndices
                : null,
          ),
        ),
      ),
    );
  }
}

class _PrimaryActionSection extends StatelessWidget {
  const _PrimaryActionSection();

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.cubit<GameCubit>();
    final isSpinning = context.selectState<GameCubit, GameState, bool>(
      selector: _isSpinning,
    );

    return FilledButton(
      onPressed: isSpinning ? null : cubit.playRound,
      child: Text(l10n.igamingDemoPlayButton),
    );
  }
}

class _ResultSummarySection extends StatelessWidget {
  const _ResultSummarySection();

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cubit = context.cubit<GameCubit>();
    final resultState = context
        .selectState<
          GameCubit,
          GameState,
          ({GameRoundResult? result, DemoBalance? balance})
        >(
          selector: (final state) => (
            result: _roundResult(state),
            balance: _displayBalance(state),
          ),
        );

    final result = resultState.result;
    final balance = resultState.balance;
    if (result == null || balance == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(height: context.responsiveGapL),
        CommonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                result.isWin
                    ? l10n.igamingDemoResultWin
                    : l10n.igamingDemoResultLoss,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: result.isWin
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: context.responsiveGapS),
              Text(
                '${l10n.igamingDemoBalanceLabel}: ${balance.amountUnits}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        SizedBox(height: context.responsiveGapM),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton(
                onPressed: cubit.playAgain,
                child: Text(l10n.igamingDemoPlayAgain),
              ),
            ),
            SizedBox(width: context.responsiveGapM),
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.go(AppRoutes.igamingDemoPath),
                child: Text(l10n.igamingDemoBackToLobby),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
