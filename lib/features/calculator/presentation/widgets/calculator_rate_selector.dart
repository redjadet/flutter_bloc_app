import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/utils/calculator_formatters.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:intl/intl.dart';

part 'calculator_rate_selector_dialog.dart';

/// Preset options for tax rate selection, expressed as fractions.
const List<double> calculatorTaxRateOptions = <double>[
  0,
  0.05,
  0.08,
  0.1,
  0.18,
];

/// Preset options for tip rate selection, expressed as fractions.
const List<double> calculatorTipRateOptions = <double>[
  0,
  0.1,
  0.15,
  0.2,
];

/// Immutable configuration for instantiating [CalculatorRateSelector].
@immutable
class CalculatorRateSelectorConfig {
  const CalculatorRateSelectorConfig({
    required this.title,
    required this.options,
    required this.customLabel,
    required this.customDialogTitle,
    required this.customFieldLabel,
    required this.customApplyLabel,
    required this.customCancelLabel,
    required this.resetLabel,
    this.suffixText,
  });

  final String title;
  final List<double> options;
  final String customLabel;
  final String customDialogTitle;
  final String customFieldLabel;
  final String customApplyLabel;
  final String customCancelLabel;
  final String resetLabel;
  final String? suffixText;
}

CalculatorRateSelectorConfig taxRateSelectorConfig(
  final AppLocalizations l10n,
) => CalculatorRateSelectorConfig(
  title: l10n.calculatorTaxPresetsLabel,
  options: calculatorTaxRateOptions,
  customLabel: l10n.calculatorCustomTaxLabel,
  customDialogTitle: l10n.calculatorCustomTaxDialogTitle,
  customFieldLabel: l10n.calculatorCustomTaxFieldLabel,
  customApplyLabel: l10n.calculatorApply,
  customCancelLabel: l10n.calculatorCancel,
  resetLabel: l10n.calculatorResetTax,
);

CalculatorRateSelectorConfig tipRateSelectorConfig(
  final AppLocalizations l10n,
) => CalculatorRateSelectorConfig(
  title: l10n.calculatorTipRateLabel,
  options: calculatorTipRateOptions,
  customLabel: l10n.calculatorCustomTipLabel,
  customDialogTitle: l10n.calculatorCustomTipDialogTitle,
  customFieldLabel: l10n.calculatorCustomTipFieldLabel,
  customApplyLabel: l10n.calculatorApply,
  customCancelLabel: l10n.calculatorCancel,
  resetLabel: l10n.calculatorResetTip,
);

/// Reusable selector for choosing percentage-based rates (e.g. tax, tip).
class CalculatorRateSelector extends StatelessWidget {
  const CalculatorRateSelector({
    required this.config,
    required this.selectedRate,
    required this.onChanged,
    required this.onReset,
    this.enabled = true,
    super.key,
  });

  final CalculatorRateSelectorConfig config;
  final double selectedRate;
  final ValueChanged<double> onChanged;
  final VoidCallback onReset;
  final bool enabled;

  @override
  Widget build(final BuildContext context) {
    final NumberFormat percentFormat = CalculatorFormatters.of(context).percent;
    final String suffix = config.suffixText ?? percentFormat.symbols.PERCENT;
    final bool hasCustomSelection =
        !config.options.contains(selectedRate) && selectedRate != 0;

    final double wrapSpacing = context.responsiveHorizontalGapM;
    final double wrapRunSpacing = context.responsiveGapM;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          config.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: context.responsiveGapS),
        Wrap(
          spacing: wrapSpacing,
          runSpacing: wrapRunSpacing,
          children: [
            for (final double option in config.options)
              ChoiceChip(
                label: Text(percentFormat.format(option)),
                selected: selectedRate == option,
                onSelected: enabled ? (_) => onChanged(option) : null,
              ),
            ChoiceChip(
              label: Text(config.customLabel),
              selected: hasCustomSelection,
              onSelected: !enabled
                  ? null
                  : (_) async {
                      final double? value = await showAdaptiveDialog<double>(
                        context: context,
                        builder: (final context) => _CustomRateDialog(
                          initialValue: selectedRate,
                          title: config.customDialogTitle,
                          fieldLabel: config.customFieldLabel,
                          applyLabel: config.customApplyLabel,
                          cancelLabel: config.customCancelLabel,
                          suffixText: suffix,
                        ),
                      );
                      if (value != null && context.mounted) {
                        onChanged(value);
                      }
                    },
            ),
            InputChip(
              label: Text(config.resetLabel),
              onPressed: enabled ? onReset : null,
            ),
          ],
        ),
      ],
    );
  }
}
