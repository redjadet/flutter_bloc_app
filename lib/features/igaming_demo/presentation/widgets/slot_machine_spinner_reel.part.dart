part of 'slot_machine_spinner.dart';

class _ReelColumn extends StatelessWidget {
  const _ReelColumn({
    required this.symbols,
    required this.scrollOffset,
    required this.symbolHeight,
    required this.reelWidth,
    required this.textStyle,
    required this.borderColor,
  });

  final List<String> symbols;
  final double scrollOffset;
  final double symbolHeight;
  final double reelWidth;
  final TextStyle? textStyle;
  final Color borderColor;

  @override
  Widget build(final BuildContext context) {
    const int repeat = 20;
    final List<String> strip = List<String>.generate(symbols.length * repeat, (
      final i,
    ) {
      return symbols[i % symbols.length];
    });
    final double clampedOffset = scrollOffset % (symbols.length * symbolHeight);

    return Container(
      width: reelWidth,
      height: symbolHeight,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(UI.radiusS),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 0,
            top: -clampedOffset,
            right: 0,
            height: strip.length * symbolHeight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: strip.map((final s) {
                return SizedBox(
                  height: symbolHeight,
                  width: reelWidth,
                  child: Center(
                    child: buildSlotSymbolWidget(
                      s,
                      textStyle: textStyle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: symbolHeight * 0.3,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    borderColor.withValues(alpha: 0.4),
                    borderColor.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: symbolHeight * 0.3,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: <Color>[
                    borderColor.withValues(alpha: 0.4),
                    borderColor.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
