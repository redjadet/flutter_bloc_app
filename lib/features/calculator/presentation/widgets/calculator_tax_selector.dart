import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/widgets/calculator_rate_selector.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';

class CalculatorTaxSelector extends StatelessWidget {
  const CalculatorTaxSelector({
    required this.percent,
    required this.onChanged,
    required this.onReset,
    super.key,
  });

  final double percent;
  final ValueChanged<double> onChanged;
  final VoidCallback onReset;

  static const List<double> _options = <double>[0, 0.05, 0.08, 0.1, 0.18];

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CalculatorRateSelector(
      title: l10n.calculatorTaxPresetsLabel,
      options: _options,
      selectedRate: percent,
      onChanged: onChanged,
      onReset: onReset,
      customLabel: l10n.calculatorCustomTaxLabel,
      customDialogTitle: l10n.calculatorCustomTaxDialogTitle,
      customFieldLabel: l10n.calculatorCustomTaxFieldLabel,
      customApplyLabel: l10n.calculatorApply,
      customCancelLabel: l10n.calculatorCancel,
      resetLabel: l10n.calculatorResetTax,
    );
  }
}
