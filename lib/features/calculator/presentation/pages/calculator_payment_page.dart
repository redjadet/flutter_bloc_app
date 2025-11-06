import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/widgets/calculator_summary_card.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:go_router/go_router.dart';

class CalculatorPaymentPage extends StatelessWidget {
  const CalculatorPaymentPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final bool isWide = context.isMediumWidth || context.isTabletOrLarger;
    final EdgeInsets padding = EdgeInsets.symmetric(
      horizontal: isWide
          ? context.pageHorizontalPadding + context.responsiveHorizontalGapL
          : context.pageHorizontalPadding,
      vertical: isWide ? context.responsiveGapL : context.responsiveGapM,
    );
    final double sectionGap = context.responsiveGapL;

    return CommonPageLayout(
      title: l10n.calculatorPaymentTitle,
      useResponsiveBody: false,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: padding,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CalculatorSummaryCard(padding: EdgeInsets.zero),
                  SizedBox(height: sectionGap * 1.5),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: context.pop,
                      child: Text(l10n.calculatorNewCalculation),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
