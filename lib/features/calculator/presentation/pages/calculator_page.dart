import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/constants.dart';
import 'package:flutter_bloc_app/features/calculator/domain/calculator_error.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/cubit/calculator_state.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/widgets/calculator_keypad.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_app_bar.dart';
import 'package:flutter_bloc_app/shared/widgets/common_max_width.dart';

class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});

  static const double _maxContentWidth = 480;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: CommonAppBar(
        title: l10n.calculatorTitle,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (final context, final constraints) {
            final bool compactHeight =
                constraints.maxHeight < AppConstants.compactHeightBreakpoint;
            final bool shouldScroll = compactHeight || context.isCompactWidth;
            final EdgeInsetsGeometry padding = EdgeInsets.symmetric(
              horizontal: context.pageHorizontalPadding,
              vertical: shouldScroll
                  ? context.responsiveGapM
                  : context.responsiveGapS,
            );
            final double verticalGap = context.responsiveGapL * 2;

            Widget content;
            if (shouldScroll) {
              content = SingleChildScrollView(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: verticalGap),
                    const _CalculatorDisplay(),
                    SizedBox(height: verticalGap),
                    const CalculatorKeypad(shrinkWrap: true),
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

            return CommonMaxWidth(
              maxWidth: _maxContentWidth,
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
  Widget build(final BuildContext context) =>
      BlocSelector<CalculatorCubit, CalculatorState, _DisplayData>(
        selector: (final state) => _DisplayData(
          display: state.display,
          history: state.history,
          error: state.error,
        ),
        builder: (final context, final data) {
          final ThemeData theme = Theme.of(context);
          final ColorScheme colors = theme.colorScheme;
          final double horizontalPadding = context.responsiveHorizontalGapL;
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
            CalculatorError.divisionByZero =>
              l10n.calculatorErrorDivisionByZero,
            CalculatorError.invalidResult => l10n.calculatorErrorInvalidResult,
            CalculatorError.nonPositiveTotal =>
              l10n.calculatorErrorNonPositiveTotal,
            null => data.display,
          };
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!hasError && data.history.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      data.history,
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
}

@immutable
class _DisplayData extends Equatable {
  const _DisplayData({
    required this.display,
    required this.history,
    required this.error,
  });

  final String display;
  final String history;
  final CalculatorError? error;

  @override
  List<Object?> get props => [display, history, error];
}
