part of 'calculator_keypad.dart';

class _CalculatorButton extends StatelessWidget {
  const _CalculatorButton({
    required this.config,
    required this.actions,
    required this.onEvaluate,
    required this.palette,
    super.key,
  });

  final _ButtonConfig config;
  final CalculatorActions actions;
  final VoidCallback onEvaluate;
  final _CalculatorPalette palette;

  @override
  Widget build(final BuildContext context) {
    final _CalculatorButtonStyle style = palette.styleFor(config.type);
    final bool triggersEvaluation = config.command is EvaluateCommand;
    final ThemeData theme = Theme.of(context);
    final bool useCupertino = PlatformAdaptive.isCupertinoFromTheme(theme);

    void handleTap() {
      config.command.execute(actions);
      if (triggersEvaluation) {
        onEvaluate();
      }
    }

    final Widget label = LayoutBuilder(
      builder: (final context, final constraints) {
        final double cellSize = math.min(
          constraints.maxWidth,
          constraints.maxHeight,
        );
        if (cellSize <= 0) {
          return const SizedBox.shrink();
        }
        // Keep labels inside the circular clip: avoid a fixed minimum font
        // (e.g. 22px) that exceeds small cells on narrow web layouts.
        final double rawInset = (cellSize * 0.12).clamp(2.0, 14.0);
        // Cap inset so padding never consumes the whole cell (tiny layouts / tests).
        final double inset = math.min(rawInset, cellSize * 0.42);
        final Widget content = config.icon == null
            ? Text(
                config.label,
                style: TextStyle(
                  color: style.foreground,
                  fontSize: cellSize * 0.85,
                  fontWeight: config.type == _ButtonType.operation
                      ? FontWeight.w600
                      : FontWeight.w500,
                  height: 1,
                ),
                maxLines: 1,
                textAlign: TextAlign.center,
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
              )
            : Icon(
                config.icon,
                color: style.foreground,
                size: cellSize * 0.54,
              );
        return SizedBox.expand(
          child: Padding(
            padding: EdgeInsets.all(inset),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: content,
            ),
          ),
        );
      },
    );

    Widget button;
    if (useCupertino) {
      button = ClipOval(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: style.background,
            shape: BoxShape.circle,
            border: Border.all(color: palette.borderColor),
          ),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(UI.radiusPill),
            onPressed: handleTap,
            child: label,
          ),
        ),
      );
    } else {
      button = Material(
        color: style.background,
        shape: CircleBorder(side: BorderSide(color: palette.borderColor)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: handleTap,
          child: label,
        ),
      );
    }

    final String? tooltip = config.tooltip;
    if (tooltip != null && tooltip.isNotEmpty) {
      button = Tooltip(message: tooltip, child: button);
    }

    final String semanticsLabel = config.semanticsLabel ?? config.label;
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: button,
    );
  }
}

class _CalculatorPalette {
  const _CalculatorPalette({
    required this.number,
    required this.function,
    required this.operation,
    required this.borderColor,
  });

  factory _CalculatorPalette.fromTheme(final ThemeData theme) {
    final ColorScheme colors = theme.colorScheme;
    return _CalculatorPalette(
      number: _CalculatorButtonStyle(
        background: colors.surfaceContainerHighest,
        foreground: colors.onSurface,
      ),
      function: _CalculatorButtonStyle(
        background: colors.secondaryContainer,
        foreground: colors.onSecondaryContainer,
      ),
      operation: _CalculatorButtonStyle(
        background: colors.primary,
        foreground: colors.onPrimary,
      ),
      borderColor: colors.outlineVariant.withValues(alpha: 0.5),
    );
  }

  final _CalculatorButtonStyle number;
  final _CalculatorButtonStyle function;
  final _CalculatorButtonStyle operation;
  final Color borderColor;

  _CalculatorButtonStyle styleFor(final _ButtonType type) => switch (type) {
    _ButtonType.number => number,
    _ButtonType.function => function,
    _ButtonType.operation => operation,
  };
}

class _CalculatorButtonStyle {
  const _CalculatorButtonStyle({
    required this.background,
    required this.foreground,
  });

  final Color background;
  final Color foreground;
}
