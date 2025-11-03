import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/widgets/calculator_summary_card.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:go_router/go_router.dart';

class CalculatorPaymentPage extends StatelessWidget {
  const CalculatorPaymentPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.calculatorPaymentTitle),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (final context, final constraints) {
            final bool isWide = constraints.maxWidth >= 640;
            final EdgeInsets padding = EdgeInsets.symmetric(
              horizontal: isWide ? 48 : 24,
              vertical: isWide ? 32 : 16,
            );
            return SingleChildScrollView(
              padding: padding,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const CalculatorSummaryCard(padding: EdgeInsets.zero),
                      const SizedBox(height: 24),
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
            );
          },
        ),
      ),
    );
  }
}
