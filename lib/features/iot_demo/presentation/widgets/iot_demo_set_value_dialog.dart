import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_value_range.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/navigation.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

/// Stateful dialog content so [TextEditingController] is disposed in
/// [State.dispose] after the route is torn down, avoiding
/// "used after being disposed".
class IotDemoSetValueDialogBody extends StatefulWidget {
  const IotDemoSetValueDialogBody({
    required this.initialValue,
    required this.l10n,
    required this.minValue,
    required this.maxValue,
    super.key,
  });

  final double initialValue;
  final AppLocalizations l10n;
  final double minValue;
  final double maxValue;

  @override
  State<IotDemoSetValueDialogBody> createState() =>
      _IotDemoSetValueDialogBodyState();
}

class _IotDemoSetValueDialogBodyState extends State<IotDemoSetValueDialogBody> {
  late final TextEditingController _controller;
  String? _errorMessage;

  static const TextInputType _decimalKeyboard = TextInputType.numberWithOptions(
    decimal: true,
  );

  @override
  void initState() {
    super.initState();
    final double v = widget.initialValue;
    _controller = TextEditingController(
      text: v == v.roundToDouble() ? v.toInt().toString() : v.toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double? get _parsedValue {
    final String normalized = _controller.text.trim().replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  void _submitValue(final BuildContext context) {
    final p = _parsedValue;
    if (p == null) {
      setState(() => _errorMessage = widget.l10n.iotDemoSetValueInvalidNumber);
      return;
    }
    if (p < widget.minValue || p > widget.maxValue) {
      setState(
        () => _errorMessage = widget.l10n.iotDemoSetValueOutOfRange(
          widget.minValue.toStringAsFixed(0),
          widget.maxValue.toStringAsFixed(0),
        ),
      );
      return;
    }
    final double clamped = iotDemoClampAndRound(
      p,
      widget.minValue,
      widget.maxValue,
    );
    NavigationUtils.maybePop(context, result: clamped);
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = widget.l10n;
    final cancelLabel = l10n.cancelButtonLabel;
    final okLabel = MaterialLocalizations.of(context).okButtonLabel;
    final useCupertino = PlatformAdaptive.isCupertinoFromTheme(
      Theme.of(context),
    );
    return useCupertino
        ? _buildCupertinoDialog(context, l10n, cancelLabel, okLabel)
        : _buildMaterialDialog(context, l10n, cancelLabel, okLabel);
  }

  Widget _buildMaterialDialog(
    final BuildContext context,
    final AppLocalizations l10n,
    final String cancelLabel,
    final String okLabel,
  ) => AlertDialog(
    title: Text(l10n.iotDemoSetValue),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: _controller,
          keyboardType: _decimalKeyboard,
          decoration: InputDecoration(
            labelText: l10n.iotDemoSetValueHint,
            errorText: _errorMessage,
          ),
          onChanged: (_) => _clearError(),
          onSubmitted: (_) => _submitValue(context),
        ),
      ],
    ),
    actions: <Widget>[
      PlatformAdaptive.dialogAction(
        context: context,
        onPressed: () => NavigationUtils.maybePop(context),
        label: cancelLabel,
      ),
      PlatformAdaptive.dialogAction(
        context: context,
        onPressed: () => _submitValue(context),
        label: okLabel,
      ),
    ],
  );

  List<Widget> _buildErrorSection(final BuildContext context) {
    if (_errorMessage case final String errorText) {
      final theme = Theme.of(context);
      return <Widget>[
        SizedBox(height: context.responsiveGapS),
        Text(
          errorText,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      ];
    }
    return const <Widget>[];
  }

  Widget _buildCupertinoDialog(
    final BuildContext context,
    final AppLocalizations l10n,
    final String cancelLabel,
    final String okLabel,
  ) => CupertinoAlertDialog(
    title: Text(l10n.iotDemoSetValue),
    content: Builder(
      builder: (final _) => Padding(
        padding: EdgeInsets.only(top: context.responsiveGapM),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CupertinoTextField(
              controller: _controller,
              keyboardType: _decimalKeyboard,
              placeholder: l10n.iotDemoSetValueHint,
              onChanged: (_) => _clearError(),
              onSubmitted: (_) => _submitValue(context),
            ),
            ..._buildErrorSection(context),
          ],
        ),
      ),
    ),
    actions: <CupertinoDialogAction>[
      CupertinoDialogAction(
        onPressed: () => NavigationUtils.maybePop(context),
        child: Text(cancelLabel),
      ),
      CupertinoDialogAction(
        onPressed: () => _submitValue(context),
        child: Text(okLabel),
      ),
    ],
  );
}
