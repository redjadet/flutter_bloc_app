import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:intl/intl.dart';

/// Reusable selector for choosing percentage-based rates (e.g. tax, tip).
class CalculatorRateSelector extends StatelessWidget {
  const CalculatorRateSelector({
    required this.title,
    required this.options,
    required this.selectedRate,
    required this.onChanged,
    required this.onReset,
    required this.customLabel,
    required this.customDialogTitle,
    required this.customFieldLabel,
    required this.customApplyLabel,
    required this.customCancelLabel,
    required this.resetLabel,
    this.suffixText = '%',
    super.key,
  });

  final String title;
  final List<double> options;
  final double selectedRate;
  final ValueChanged<double> onChanged;
  final VoidCallback onReset;
  final String customLabel;
  final String customDialogTitle;
  final String customFieldLabel;
  final String customApplyLabel;
  final String customCancelLabel;
  final String resetLabel;
  final String suffixText;

  @override
  Widget build(final BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final String localeName = Intl.canonicalizedLocale(locale.toString());
    final NumberFormat percentFormat = NumberFormat.percentPattern(localeName);
    final bool hasCustomSelection =
        !options.contains(selectedRate) && selectedRate != 0;

    final double wrapSpacing = context.responsiveHorizontalGapM;
    final double wrapRunSpacing = context.responsiveGapM;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: context.responsiveGapS),
        Wrap(
          spacing: wrapSpacing,
          runSpacing: wrapRunSpacing,
          children: [
            for (final double option in options)
              ChoiceChip(
                label: Text(percentFormat.format(option)),
                selected: selectedRate == option,
                onSelected: (_) => onChanged(option),
              ),
            ChoiceChip(
              label: Text(customLabel),
              selected: hasCustomSelection,
              onSelected: (_) async {
                final double? value = await showDialog<double>(
                  context: context,
                  builder: (final context) => _CustomRateDialog(
                    initialValue: selectedRate,
                    title: customDialogTitle,
                    fieldLabel: customFieldLabel,
                    applyLabel: customApplyLabel,
                    cancelLabel: customCancelLabel,
                    suffixText: suffixText,
                  ),
                );
                if (value != null && context.mounted) {
                  onChanged(value);
                }
              },
            ),
            InputChip(
              label: Text(resetLabel),
              onPressed: onReset,
            ),
          ],
        ),
      ],
    );
  }
}

class _CustomRateDialog extends StatefulWidget {
  const _CustomRateDialog({
    required this.initialValue,
    required this.title,
    required this.fieldLabel,
    required this.applyLabel,
    required this.cancelLabel,
    required this.suffixText,
  });

  final double initialValue;
  final String title;
  final String fieldLabel;
  final String applyLabel;
  final String cancelLabel;
  final String suffixText;

  @override
  State<_CustomRateDialog> createState() => _CustomRateDialogState();
}

class _CustomRateDialogState extends State<_CustomRateDialog> {
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
  Widget build(final BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      autofocus: true,
      decoration: InputDecoration(
        labelText: widget.fieldLabel,
        suffixText: widget.suffixText,
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
        child: Text(widget.cancelLabel),
      ),
      TextButton(
        onPressed: _parsedValue == null
            ? null
            : () => Navigator.of(context).pop(_parsedValue),
        child: Text(widget.applyLabel),
      ),
    ],
  );
}
