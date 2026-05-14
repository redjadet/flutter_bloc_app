import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/entities/market_connection_status.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/entities/market_feed_snapshot.dart';
import 'package:flutter_bloc_app/features/realtime_market/presentation/cubit/realtime_market_cubit.dart';
import 'package:flutter_bloc_app/features/realtime_market/presentation/cubit/realtime_market_state.dart';
import 'package:flutter_bloc_app/features/realtime_market/presentation/widgets/market_chart_panel.dart';
import 'package:flutter_bloc_app/features/realtime_market/presentation/widgets/market_header.dart';
import 'package:flutter_bloc_app/features/realtime_market/presentation/widgets/market_side_tabs.dart';
import 'package:flutter_bloc_app/features/realtime_market/presentation/widgets/market_stats_strip.dart';
import 'package:flutter_bloc_app/features/realtime_market/presentation/widgets/order_book_panel.dart';
import 'package:flutter_bloc_app/features/realtime_market/presentation/widgets/recent_trades_panel.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

class RealtimeMarketLoadErrorBanner extends StatelessWidget {
  const RealtimeMarketLoadErrorBanner({required this.l10n, super.key});

  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.errorContainer.withValues(alpha: 0.85),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(context.responsiveGapM),
        child: LayoutBuilder(
          builder: (final context, final constraints) {
            final bool stackAction = constraints.maxWidth < 420;
            final Widget message = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.cloud_off_rounded, color: scheme.onErrorContainer),
                SizedBox(width: context.responsiveGapM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.realtimeMarketLoadError,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: scheme.onErrorContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: context.responsiveGapXS),
                      Text(
                        l10n.realtimeMarketPullToRefreshHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onErrorContainer.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
            final Widget retryButton = Align(
              alignment: stackAction
                  ? AlignmentDirectional.centerStart
                  : AlignmentDirectional.topEnd,
              child: PlatformAdaptive.textButton(
                context: context,
                onPressed: () =>
                    context.cubit<RealtimeMarketCubit>().reconnect(),
                child: Text(l10n.realtimeMarketRetryButton),
              ),
            );
            if (stackAction) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  message,
                  SizedBox(height: context.responsiveGapS),
                  retryButton,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: message),
                SizedBox(width: context.responsiveGapS),
                retryButton,
              ],
            );
          },
        ),
      ),
    );
  }
}

class RealtimeMarketEmptyOrErrorBody extends StatelessWidget {
  const RealtimeMarketEmptyOrErrorBody({required this.l10n, super.key});

  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveGapL,
          vertical: context.responsiveGapL * 2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insert_chart_outlined_rounded,
              size: 48,
              color: scheme.onSurfaceVariant,
            ),
            SizedBox(height: context.responsiveGapM),
            Text(
              l10n.realtimeMarketLoadError,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: context.responsiveGapS),
            Text(
              l10n.realtimeMarketPullToRefreshHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: context.responsiveGapL),
            FilledButton.icon(
              onPressed: () => context.cubit<RealtimeMarketCubit>().reconnect(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.realtimeMarketRetryButton),
            ),
          ],
        ),
      ),
    );
  }
}

class RealtimeMarketSkeletonPlaceholder extends StatelessWidget {
  const RealtimeMarketSkeletonPlaceholder({super.key});

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('BTC/USDT', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text('00000.00', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 24),
        Text(
          'Lorem ipsum dolor sit',
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}

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
