import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:intl/intl.dart';

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
    final Locale locale = Localizations.localeOf(context);
    final String localeName = Intl.canonicalizedLocale(locale.toString());
    final NumberFormat percentFormat = NumberFormat.percentPattern(localeName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.calculatorTipRateLabel,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final double option in _tipOptions)
              ChoiceChip(
                label: Text(percentFormat.format(option)),
                selected: selectedRate == option,
                onSelected: (_) => onChanged(option),
              ),
            ChoiceChip(
              label: Text(l10n.calculatorCustomTipLabel),
              selected:
                  !_tipOptions.contains(selectedRate) && selectedRate != 0,
              onSelected: (_) async {
                final double? custom = await showDialog<double>(
                  context: context,
                  builder: (final context) => _CustomTipDialog(
                    initialValue: selectedRate,
                  ),
                );
                if (custom != null && context.mounted) {
                  onChanged(custom);
                }
              },
            ),
            InputChip(
              label: Text(l10n.calculatorResetTip),
              onPressed: onReset,
            ),
          ],
        ),
      ],
    );
  }
}

class _CustomTipDialog extends StatefulWidget {
  const _CustomTipDialog({required this.initialValue});

  final double initialValue;

  @override
  State<_CustomTipDialog> createState() => _CustomTipDialogState();
}

class _CustomTipDialogState extends State<_CustomTipDialog> {
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
      title: Text(l10n.calculatorCustomTipDialogTitle),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        autofocus: true,
        decoration: InputDecoration(
          labelText: l10n.calculatorCustomTipFieldLabel,
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
