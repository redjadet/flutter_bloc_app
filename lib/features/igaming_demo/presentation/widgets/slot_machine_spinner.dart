import 'dart:async';

import 'package:flutter/material.dart';

/// Symbols shown on each reel (slot-machine style). Exposed for legend.
const List<String> kSlotReelSymbols = <String>['7', '★', '◆', '●', '▲', '♦'];

/// Height of one symbol cell in the reel window.
const double _symbolHeight = 48;

/// Width of one reel column.
const double _reelWidth = 56;

/// Number of full cycles to scroll during the spin (then ease out).
const int _spinCycles = 8;

/// Slot-machine style spinner: reels that spin for [duration] then stop.
///
/// When [staticProgress] is non-null, reels are shown at that progress (0.0–1.0)
/// with no animation—e.g. use 1.0 to show the final spin result.
///
/// When [targetSymbolIndices] is non-null (length 3), each reel lands on that
/// symbol index so the result matches the game outcome (three matching = win).
class SlotMachineSpinner extends StatefulWidget {
  const SlotMachineSpinner({
    required this.duration,
    this.staticProgress,
    this.targetSymbolIndices,
    super.key,
  });

  final Duration duration;

  /// If set, reels are drawn at this progress and no animation runs.
  final double? staticProgress;

  /// If set (length 3), each reel animates to show this symbol index at progress 1.0.
  final List<int>? targetSymbolIndices;

  @override
  State<SlotMachineSpinner> createState() => _SlotMachineSpinnerState();
}

class _SlotMachineSpinnerState extends State<SlotMachineSpinner>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    if (widget.staticProgress == null) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    if (_controller != null) return;
    final controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _controller = controller;
    _animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    );
    unawaited(controller.forward());
  }

  @override
  void didUpdateWidget(final SlotMachineSpinner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.staticProgress == null && widget.staticProgress != null) {
      _controller?.dispose();
      _controller = null;
      _animation = null;
    } else if (widget.staticProgress == null && _controller == null) {
      _startAnimation();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _buildReelsAt(final double progress) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final double cycleHeight = kSlotReelSymbols.length * _symbolHeight;
    final List<int>? target = widget.targetSymbolIndices;
    final bool useTargets = target != null && target.length == 3;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(3, (final reelIndex) {
        final double reelOffset;
        if (useTargets) {
          final int idx = target[reelIndex].clamp(
            0,
            kSlotReelSymbols.length - 1,
          );
          final double targetOffset =
              idx * _symbolHeight + _spinCycles * cycleHeight;
          reelOffset = (progress * targetOffset) % cycleHeight;
        } else {
          final double maxOffset = _spinCycles * cycleHeight;
          final double baseOffset = (progress * maxOffset) % cycleHeight;
          final double phase = reelIndex * (cycleHeight / 3);
          reelOffset = (baseOffset + phase) % cycleHeight;
        }
        return _ReelColumn(
          symbols: kSlotReelSymbols,
          scrollOffset: reelOffset,
          symbolHeight: _symbolHeight,
          reelWidth: _reelWidth,
          textStyle: textTheme.headlineSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
          borderColor: colorScheme.outline,
        );
      }),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final double? staticProgress = widget.staticProgress;
    if (staticProgress != null) {
      return _buildReelsAt(staticProgress);
    }
    final animation = _animation;
    if (animation == null) {
      return _buildReelsAt(0);
    }
    return AnimatedBuilder(
      animation: animation,
      builder: (final context, final _) => _buildReelsAt(animation.value),
    );
  }
}

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
        borderRadius: BorderRadius.circular(8),
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
                    child: Text(
                      s,
                      style: textStyle,
                      semanticsLabel: s,
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
