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
    return Semantics(
      label: '${l10n.realtimeMarketSideBuy}, ${l10n.realtimeMarketSideSell}',
      child: SegmentedButton<RealtimeMarketSideTab>(
        segments: <ButtonSegment<RealtimeMarketSideTab>>[
          ButtonSegment<RealtimeMarketSideTab>(
            value: RealtimeMarketSideTab.bids,
            icon: const Icon(Icons.trending_up, size: 18),
            label: Text(l10n.realtimeMarketSideBuy),
          ),
          ButtonSegment<RealtimeMarketSideTab>(
            value: RealtimeMarketSideTab.asks,
            icon: const Icon(Icons.trending_down, size: 18),
            label: Text(l10n.realtimeMarketSideSell),
          ),
        ],
        selected: <RealtimeMarketSideTab>{selected},
        onSelectionChanged: (final next) {
          onChanged(next.first);
        },
      ),
    );
  }
}
