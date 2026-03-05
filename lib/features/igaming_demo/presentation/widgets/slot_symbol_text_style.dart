import 'package:flutter/material.dart';

/// The "gem" symbol used by the slot reels/legend.
const String kSlotGemSymbol = '♦';

/// Unicode slot symbols that are rendered as [Icon] so they display reliably
/// on all platforms (e.g. iOS simulator where font glyphs can be missing).
const Map<String, IconData> kSlotSymbolToIcon = <String, IconData>{
  '♦': Icons.diamond,
  '★': Icons.star,
  '◆': Icons.diamond_outlined,
  '●': Icons.circle,
  '▲': Icons.change_history,
};

/// Font fallback for the digit '7' and any symbol not in [kSlotSymbolToIcon].
const List<String> kSlotSymbolFontFamilyFallback = <String>[
  'AppleColorEmoji',
  'SF Pro',
  'Noto Sans Symbols2',
  'Noto Sans Symbols',
  'Segoe UI Symbol',
];

TextStyle? withSlotSymbolFallback(final TextStyle? base) =>
    base?.copyWith(fontFamilyFallback: kSlotSymbolFontFamilyFallback);

/// Builds a widget for a slot symbol that is robust across platforms/fonts.
/// Symbols in [kSlotSymbolToIcon] use [Icon]; others use [Text] with fallback.
Widget buildSlotSymbolWidget(
  final String symbol, {
  required final TextStyle? textStyle,
  required final Color color,
}) {
  final IconData? iconData = kSlotSymbolToIcon[symbol];
  if (iconData != null) {
    return Icon(
      iconData,
      color: color,
      size: textStyle?.fontSize,
      semanticLabel: symbol,
    );
  }
  return Text(
    symbol,
    style: withSlotSymbolFallback(textStyle),
    semanticsLabel: symbol,
  );
}
