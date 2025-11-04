import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/widgets/calculator_rate_selector.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';

class CalculatorTipSelector extends StatelessWidget {
  const CalculatorTipSelector({
    required this.selectedRate,
    required this.onChanged,
    required this.onReset,
    super.key,
  });

  final double selectedRate;
  final ValueChanged<double> onChanged;
  final VoidCallback onReset;

  static const List<double> _tipOptions = <double>[0, 0.1, 0.15, 0.2];

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CalculatorRateSelector(
      title: l10n.calculatorTipRateLabel,
      options: _tipOptions,
      selectedRate: selectedRate,
      onChanged: onChanged,
      onReset: onReset,
      customLabel: l10n.calculatorCustomTipLabel,
      customDialogTitle: l10n.calculatorCustomTipDialogTitle,
      customFieldLabel: l10n.calculatorCustomTipFieldLabel,
      customApplyLabel: l10n.calculatorApply,
      customCancelLabel: l10n.calculatorCancel,
      resetLabel: l10n.calculatorResetTip,
    );
  }
}
