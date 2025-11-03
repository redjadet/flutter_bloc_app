import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:intl/intl.dart';

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
    final Locale locale = Localizations.localeOf(context);
    final String localeName = Intl.canonicalizedLocale(locale.toString());
    final NumberFormat percentFormat = NumberFormat.percentPattern(localeName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.calculatorTaxPresetsLabel,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final double option in _options)
              ChoiceChip(
                label: Text(percentFormat.format(option)),
                selected: percent == option,
                onSelected: (_) => onChanged(option),
              ),
            ChoiceChip(
              label: Text(l10n.calculatorCustomTaxLabel),
              selected: !_options.contains(percent) && percent != 0,
              onSelected: (_) async {
                final double? value = await showDialog<double>(
                  context: context,
                  builder: (final context) => _CustomTaxDialog(
                    initialValue: percent,
                  ),
                );
                if (value != null && context.mounted) {
                  onChanged(value);
                }
              },
            ),
            InputChip(
              label: Text(l10n.calculatorResetTax),
              onPressed: onReset,
            ),
          ],
        ),
      ],
    );
  }
}

class _CustomTaxDialog extends StatefulWidget {
  const _CustomTaxDialog({required this.initialValue});

  final double initialValue;

  @override
  State<_CustomTaxDialog> createState() => _CustomTaxDialogState();
}

class _CustomTaxDialogState extends State<_CustomTaxDialog> {
  late final TextEditingController _controller;
  double? _parsedValue;

  @override
  void initState() {
    super.initState();
    _parsedValue = widget.initialValue;
    _controller = TextEditingController(
      text: (widget.initialValue * 100).toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.calculatorCustomTaxDialogTitle),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        autofocus: true,
        decoration: InputDecoration(
          labelText: l10n.calculatorCustomTaxFieldLabel,
          suffixText: '%',
        ),
        onChanged: (final value) {
          final double? parsed = double.tryParse(value);
          setState(() {
            _parsedValue = parsed == null ? null : (parsed / 100).clamp(0, 1);
          });
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.calculatorCancel),
        ),
        TextButton(
          onPressed: _parsedValue == null
              ? null
              : () => Navigator.of(context).pop(_parsedValue),
          child: Text(l10n.calculatorApply),
        ),
      ],
    );
  }
}
