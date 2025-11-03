import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/calculator/domain/payment_calculator.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/cubit/calculator_state.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/widgets/calculator_tax_selector.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/widgets/calculator_tip_selector.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:intl/intl.dart';

class CalculatorSummaryCard extends StatelessWidget {
  const CalculatorSummaryCard({required this.padding, super.key});

  final EdgeInsets padding;

  @override
  Widget build(final BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final String localeName = Intl.canonicalizedLocale(locale.toString());
    final NumberFormat currency = NumberFormat.simpleCurrency(
      locale: localeName,
    );
    final NumberFormat percent = NumberFormat.percentPattern(localeName);

    return BlocBuilder<CalculatorCubit, CalculatorState>(
      buildWhen: (final previous, final current) => previous != current,
      builder: (final context, final state) {
        final l10n = context.l10n;
        final CalculatorCubit cubit = context.read<CalculatorCubit>();
        final PaymentCalculator calculator = cubit.calculator;
        final double subtotal = state.subtotal(calculator);
        final double tax = state.taxAmount(calculator);
        final double tip = state.tipAmount(calculator);
        final double total = state.total(calculator);

        return Padding(
          padding: padding,
          child: Card(
            elevation: 1,
            child: LayoutBuilder(
              builder: (final context, final constraints) {
                final BoxConstraints scrollConstraints =
                    constraints.maxHeight.isFinite
                    ? BoxConstraints(minHeight: constraints.maxHeight)
                    : const BoxConstraints();
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: scrollConstraints,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.history.isNotEmpty) ...[
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              state.history,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        Text(
                          l10n.calculatorSummaryHeader,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _SummaryRow(
                          label: l10n.calculatorResultLabel,
                          value: state.display,
                        ),
                        const SizedBox(height: 12),
                        CalculatorTaxSelector(
                          percent: state.taxRate,
                          onChanged: cubit.setTaxRate,
                          onReset: cubit.resetTax,
                        ),
                        const SizedBox(height: 24),
                        CalculatorTipSelector(
                          selectedRate: state.tipRate,
                          onChanged: cubit.setTipRate,
                          onReset: cubit.resetTip,
                        ),
                        const Divider(height: 32),
                        _SummaryRow(
                          label: l10n.calculatorSubtotalLabel,
                          value: currency.format(subtotal),
                        ),
                        const SizedBox(height: 8),
                        _SummaryRow(
                          label: l10n.calculatorTaxLabel(
                            percent.format(state.taxRate),
                          ),
                          value: currency.format(tax),
                        ),
                        const SizedBox(height: 8),
                        _SummaryRow(
                          label: l10n.calculatorTipLabel(
                            percent.format(state.tipRate),
                          ),
                          value: currency.format(tip),
                        ),
                        const Divider(height: 32),
                        _SummaryRow(
                          label: l10n.calculatorTotalLabel,
                          value: currency.format(total),
                          highlight: true,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(final BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? labelStyle = highlight
        ? textTheme.titleMedium
        : textTheme.bodyMedium;
    final TextStyle? valueStyle = highlight
        ? textTheme.headlineSmall
        : textTheme.titleMedium;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(label, style: labelStyle)),
        const SizedBox(width: 12),
        Text(value, style: valueStyle, textAlign: TextAlign.right),
      ],
    );
  }
}
