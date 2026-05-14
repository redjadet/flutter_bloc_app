import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/realtime_market/presentation/cubit/realtime_market_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

class MarketSideTabs extends StatelessWidget {
  const MarketSideTabs({
    required this.selected,
    required this.onChanged,
    required this.l10n,
    super.key,
  });

  final RealtimeMarketSideTab selected;
  final ValueChanged<RealtimeMarketSideTab> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) {
    return LayoutBuilder(
      builder: (final context, final constraints) {
        final bool labelsFit = constraints.maxWidth >= 340;
        return Semantics(
          label:
              '${l10n.realtimeMarketSideBuy}, ${l10n.realtimeMarketSideSell}',
          child: SegmentedButton<RealtimeMarketSideTab>(
            showSelectedIcon: labelsFit,
            segments: <ButtonSegment<RealtimeMarketSideTab>>[
              ButtonSegment<RealtimeMarketSideTab>(
                value: RealtimeMarketSideTab.bids,
                icon: const Icon(Icons.trending_up, size: 18),
                tooltip: l10n.realtimeMarketSideBuy,
                label: labelsFit ? Text(l10n.realtimeMarketSideBuy) : null,
              ),
              ButtonSegment<RealtimeMarketSideTab>(
                value: RealtimeMarketSideTab.asks,
                icon: const Icon(Icons.trending_down, size: 18),
                tooltip: l10n.realtimeMarketSideSell,
                label: labelsFit ? Text(l10n.realtimeMarketSideSell) : null,
              ),
            ],
            selected: <RealtimeMarketSideTab>{selected},
            onSelectionChanged: (final next) {
              onChanged(next.first);
            },
          ),
        );
      },
    );
  }
}
