import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/constants/constants.dart';
import 'package:flutter_bloc_app/features/calculator/domain/calculator_error.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/cubit/calculator_state.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/widgets/calculator_keypad.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_max_width.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/shared/widgets/type_safe_bloc_selector.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'calculator_page.freezed.dart';

/// Calculator screen with keypad, display, and optional tax/tip.
class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});

  static const double _maxContentWidthCompact = 480;
  static const double _maxContentWidthWide = 720;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.calculatorTitle,
      useResponsiveBody: false,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (final context, final constraints) {
            final bool compactHeight =
                constraints.maxHeight < AppConstants.compactHeightBreakpoint;
            final bool shouldScroll = compactHeight || context.isCompactWidth;
            final EdgeInsetsGeometry padding = context
                .pageHorizontalPaddingWithVertical(
                  shouldScroll
                      ? context.responsiveGapM
                      : context.responsiveGapS,
                );
            final double verticalGap = context.responsiveGapL * 2;

            Widget content;
            if (shouldScroll) {
              final EdgeInsets resolvedPadding = padding.resolve(
                Directionality.of(context),
              );
              final double availableWidth =
                  constraints.maxWidth -
                  resolvedPadding.left -
                  resolvedPadding.right;
              final double rawSpacing = context.responsiveGapL;
              const int columns = 4;
              const int rows = 5;
              final double contentWidth = math.max(0, availableWidth);
              final double spacing = math.min(
                rawSpacing,
                contentWidth / (columns - 1),
              );
              final double itemWidth =
                  (contentWidth - (spacing * (columns - 1))) / columns;
              final double keypadHeight =
                  (itemWidth * rows) + (spacing * (rows - 1)) + spacing;

              content = SingleChildScrollView(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: verticalGap),
                    const _CalculatorDisplay(),
                    SizedBox(height: verticalGap),
                    SizedBox(
                      height: keypadHeight,
                      child: const CalculatorKeypad(),
                    ),
                    SizedBox(height: verticalGap),
                  ],
                ),
              );
            } else {
              content = SizedBox(
                height: constraints.maxHeight,
                child: Padding(
                  padding: padding,
                  child: const _CalculatorBody(),
                ),
              );
            }

            final double maxWidth = constraints.maxWidth < _maxContentWidthWide
                ? _maxContentWidthCompact
                : _maxContentWidthWide;
            return CommonMaxWidth(
              maxWidth: maxWidth,
              child: content,
            );
          },
        ),
      ),
    );
  }
}

class _CalculatorBody extends StatelessWidget {
  const _CalculatorBody();

  @override
  Widget build(final BuildContext context) {
    final double sectionGap = context.responsiveGapL * 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: sectionGap),
        const _CalculatorDisplay(),
        SizedBox(height: sectionGap),
        const Expanded(child: CalculatorKeypad()),
      ],
    );
  }
}

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
              .clamp(
                minPad,
                maxPad,
              );
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
