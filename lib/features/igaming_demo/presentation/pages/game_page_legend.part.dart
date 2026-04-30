part of 'game_page.dart';

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
