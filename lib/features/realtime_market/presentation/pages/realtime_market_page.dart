import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RealtimeMarketPage extends StatelessWidget {
  const RealtimeMarketPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return CommonPageLayout(
      title: l10n.realtimeMarketTitle,
      body: RefreshIndicator(
        onRefresh: () => context.cubit<RealtimeMarketCubit>().reconnect(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child:
                  BlocSelector<RealtimeMarketCubit, RealtimeMarketState, bool>(
                    selector: (final s) => s.loadErrorMessage != null,
                    builder: (final context, final hasError) {
                      if (!hasError) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: context.responsiveGapS,
                        ),
                    child: Card(
                      margin: EdgeInsets.zero,
                      elevation: 0,
                      color: scheme.errorContainer.withValues(alpha: 0.85),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(context.responsiveGapM),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.cloud_off_rounded,
                              color: scheme.onErrorContainer,
                            ),
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
                            PlatformAdaptive.textButton(
                              context: context,
                              onPressed: () => context.cubit<RealtimeMarketCubit>().reconnect(),
                              child: Text(l10n.realtimeMarketRetryButton),
                            ),
                          ],
                        ),
                      ),
                    ),
                      );
                    },
                  ),
            ),
            SliverToBoxAdapter(
              child: BlocBuilder<RealtimeMarketCubit, RealtimeMarketState>(
                buildWhen: (final a, final b) =>
                    a.snapshot != b.snapshot ||
                    a.bootstrapComplete != b.bootstrapComplete ||
                    a.sideTab != b.sideTab,
                builder: (final context, final state) {
                  final bool showSkeleton =
                      !state.bootstrapComplete && state.snapshot == null;
                  final MarketFeedSnapshot? snap = state.snapshot;
                  final Widget inner = showSkeleton
                      ? _SkeletonPlaceholder()
                      : snap == null
                      ? _EmptyOrErrorBody(l10n: l10n)
                      : _LoadedMarketContent(
                          snapshot: snap,
                          sideTab: state.sideTab,
                          l10n: l10n,
                        );
                  return Skeletonizer(
                    enabled: showSkeleton,
                    effect: ShimmerEffect(
                      baseColor: theme.colorScheme.surfaceContainerHighest,
                      highlightColor: theme.colorScheme.surface,
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: context.responsiveGapL),
                      child: inner,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyOrErrorBody extends StatelessWidget {
  const _EmptyOrErrorBody({required this.l10n});

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

class _SkeletonPlaceholder extends StatelessWidget {
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

class _LoadedMarketContent extends StatelessWidget {
  const _LoadedMarketContent({
    required this.snapshot,
    required this.sideTab,
    required this.l10n,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MarketHeader(snapshot: snapshot, l10n: l10n),
        if (snapshot.connection != MarketConnectionStatus.live)
          Padding(
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
          ),
        SizedBox(height: context.responsiveGapM),
        MarketSideTabs(
          selected: sideTab,
          l10n: l10n,
          onChanged: context.cubit<RealtimeMarketCubit>().setSideTab,
        ),
        SizedBox(height: context.responsiveGapM),
        OrderBookPanel(
          bids: snapshot.bids,
          asks: snapshot.asks,
          l10n: l10n,
          bidFlex: bidFlex,
          askFlex: askFlex,
        ),
        SizedBox(height: context.responsiveGapL),
        RecentTradesPanel(trades: snapshot.recentTrades, l10n: l10n),
        SizedBox(height: context.responsiveGapL),
        MarketStatsStrip(stats: snapshot.stats, l10n: l10n),
        SizedBox(height: context.responsiveGapL),
        MarketChartPanel(closes: snapshot.chartCloses, l10n: l10n),
      ],
    );
  }
}
