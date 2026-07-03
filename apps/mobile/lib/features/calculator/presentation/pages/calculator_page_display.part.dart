part of 'calculator_page.dart';

class _CalculatorDisplay extends StatelessWidget {
  const _CalculatorDisplay();

  @override
  Widget build(
    final BuildContext context,
  ) => TypeSafeBlocSelector<CalculatorCubit, CalculatorState, _DisplayData>(
    selector: (final state) => _DisplayData(
      display: state.display,
      history: state.history,
      error: state.error,
    ),
    builder: (final context, final data) {
      final ThemeData theme = Theme.of(context);
      final ColorScheme colors = theme.colorScheme;
      final double historySpacing = context.responsiveGapS;
      final TextStyle historyStyle =
          theme.textTheme.titleMedium?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w400,
          ) ??
          TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 24,
            fontWeight: FontWeight.w400,
          );
      final TextStyle displayStyle =
          theme.textTheme.displayLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w300,
          ) ??
          TextStyle(
            color: colors.onSurface,
            fontSize: 64,
            fontWeight: FontWeight.w300,
          );
      final l10n = context.l10n;
      final bool hasError = data.error != null;
      final TextStyle effectiveDisplayStyle = hasError
          ? displayStyle.copyWith(color: colors.error)
          : displayStyle;
      final String displayText = switch (data.error) {
        CalculatorError.divisionByZero => l10n.calculatorErrorDivisionByZero,
        CalculatorError.invalidResult => l10n.calculatorErrorInvalidResult,
        CalculatorError.nonPositiveTotal =>
          l10n.calculatorErrorNonPositiveTotal,
        null => data.display,
      };
      return LayoutBuilder(
        builder: (final context, final constraints) {
          final double maxPad = constraints.maxWidth * 0.12;
          final double minPad = math.min(12, maxPad).toDouble();
          final double safeHorizontalPadding = context.responsiveHorizontalGapL
              .clamp(minPad, maxPad);
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: safeHorizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!hasError && data.history.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      data.history,
                      key: const ValueKey('calculator-history-text'),
                      style: historyStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: historySpacing),
                ],
                Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      displayText,
                      key: const ValueKey('calculator-display-text'),
                      style: effectiveDisplayStyle,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

@freezed
abstract class _DisplayData with _$DisplayData {
  const factory _DisplayData({
    required final String display,
    required final String history,
    required final CalculatorError? error,
  }) = __DisplayData;
}
