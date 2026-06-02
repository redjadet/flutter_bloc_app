part of 'realtime_market_page_body.dart';

class RealtimeMarketLoadedBody extends StatelessWidget {
  const RealtimeMarketLoadedBody({
    required this.snapshot,
    required this.sideTab,
    required this.l10n,
    super.key,
  });

  final MarketFeedSnapshot snapshot;
  final RealtimeMarketSideTab sideTab;
  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) {
    final int bidFlex = sideTab == RealtimeMarketSideTab.bids ? 2 : 1;
    final int askFlex = sideTab == RealtimeMarketSideTab.asks ? 2 : 1;
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return LayoutBuilder(
      builder: (final context, final constraints) {
        final bool wide = constraints.maxWidth >= 760;
        final bool compactBook = constraints.maxWidth < 520;
        final Widget staleBanner =
            snapshot.connection == MarketConnectionStatus.live
            ? const SizedBox.shrink()
            : Padding(
                padding: EdgeInsets.only(top: context.responsiveGapM),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.responsiveGapM,
                      vertical: context.responsiveGapS,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.history_toggle_off_rounded,
                          size: 20,
                          color: scheme.onSecondaryContainer,
                        ),
                        SizedBox(width: context.responsiveGapS),
                        Expanded(
                          child: Text(
                            l10n.realtimeMarketStaleDataLabel,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSecondaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );

        final Widget orderBook = OrderBookPanel(
          bids: snapshot.bids,
          asks: snapshot.asks,
          l10n: l10n,
          bidFlex: bidFlex,
          askFlex: askFlex,
          compactSide: compactBook ? sideTab : null,
        );

        final Widget secondaryColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarketStatsStrip(stats: snapshot.stats, l10n: l10n),
            SizedBox(height: context.responsiveGapL),
            MarketChartPanel(closes: snapshot.chartCloses, l10n: l10n),
            SizedBox(height: context.responsiveGapL),
            RecentTradesPanel(trades: snapshot.recentTrades, l10n: l10n),
          ],
        );

        final Widget marketBody = wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: orderBook),
                  SizedBox(width: context.responsiveGapL),
                  Expanded(flex: 5, child: secondaryColumn),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  orderBook,
                  SizedBox(height: context.responsiveGapL),
                  RecentTradesPanel(trades: snapshot.recentTrades, l10n: l10n),
                  SizedBox(height: context.responsiveGapL),
                  MarketStatsStrip(stats: snapshot.stats, l10n: l10n),
                  SizedBox(height: context.responsiveGapL),
                  MarketChartPanel(closes: snapshot.chartCloses, l10n: l10n),
                ],
              );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarketHeader(snapshot: snapshot, l10n: l10n),
            staleBanner,
            SizedBox(height: context.responsiveGapM),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: MarketSideTabs(
                selected: sideTab,
                l10n: l10n,
                onChanged: context.cubit<RealtimeMarketCubit>().setSideTab,
              ),
            ),
            SizedBox(height: context.responsiveGapM),
            marketBody,
          ],
        );
      },
    );
  }
}
