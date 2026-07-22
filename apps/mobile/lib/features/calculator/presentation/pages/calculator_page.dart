import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/calculator/domain/calculator_error.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/cubit/calculator_state.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/widgets/calculator_keypad.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';

part 'calculator_page.freezed.dart';
part 'calculator_page_display.part.dart';

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
                constraints.maxHeight <
                LayoutBreakpoints.compactHeightBreakpoint;
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
