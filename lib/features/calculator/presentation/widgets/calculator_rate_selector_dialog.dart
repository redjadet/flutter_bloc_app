part of 'calculator_rate_selector.dart';

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
  Widget build(final BuildContext context) {
    final bool useCupertino = PlatformAdaptive.isCupertinoFromTheme(
      Theme.of(context),
    );

    return useCupertino
        ? _buildCupertinoDialog(context)
        : _buildMaterialDialog(context);
  }

  void _handleChanged(final String value) {
    final double? parsed = double.tryParse(value);
    setState(() {
      _parsedValue = parsed == null ? null : (parsed / 100).clamp(0, 1);
    });
  }

  Widget _buildMaterialDialog(final BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      autofocus: true,
      decoration: InputDecoration(
        labelText: widget.fieldLabel,
        suffixText: widget.suffixText,
      ),
      onChanged: _handleChanged,
    ),
    actions: [
      PlatformAdaptive.dialogAction(
        context: context,
        onPressed: () => Navigator.of(context).pop(),
        label: widget.cancelLabel,
      ),
      PlatformAdaptive.dialogAction(
        context: context,
        onPressed: _parsedValue == null
            ? null
            : () => Navigator.of(context).pop(_parsedValue),
        label: widget.applyLabel,
      ),
    ],
  );

  Widget _buildCupertinoDialog(final BuildContext context) =>
      CupertinoAlertDialog(
        title: Text(widget.title),
        content: Builder(
          builder: (final BuildContext context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: context.responsiveGapM),
              CupertinoTextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                placeholder: widget.fieldLabel,
                suffix: Padding(
                  padding: EdgeInsets.only(
                    right: context.responsiveHorizontalGapS,
                  ),
                  child: Text(widget.suffixText),
                ),
                onChanged: _handleChanged,
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(widget.cancelLabel),
          ),
          CupertinoDialogAction(
            onPressed: _parsedValue == null
                ? null
                : () => Navigator.of(context).pop(_parsedValue),
            child: Text(widget.applyLabel),
          ),
        ],
      );
}
