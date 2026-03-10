import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_value_range.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/utils/iot_demo_device_type_label.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/navigation.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

/// Result of the add device dialog: name, type, and optional initial value.
class IotDemoAddDeviceResult {
  const IotDemoAddDeviceResult({
    required this.name,
    required this.type,
    this.initialValue = 0,
  });

  final String name;
  final IotDeviceType type;
  final double initialValue;
}

/// Stateful dialog content so [TextEditingController] is disposed in
/// [State.dispose] after the route is torn down.
class IotDemoAddDeviceDialogBody extends StatefulWidget {
  const IotDemoAddDeviceDialogBody({
    required this.l10n,
    super.key,
  });

  final AppLocalizations l10n;

  @override
  State<IotDemoAddDeviceDialogBody> createState() =>
      _IotDemoAddDeviceDialogBodyState();
}

class _IotDemoAddDeviceDialogBodyState
    extends State<IotDemoAddDeviceDialogBody> {
  late final TextEditingController _nameController;
  IotDeviceType _selectedType = IotDeviceType.light;
  String? _nameError;
  double _initialValue = 0;

  static const List<IotDeviceType> _types = <IotDeviceType>[
    IotDeviceType.light,
    IotDeviceType.thermostat,
    IotDeviceType.plug,
    IotDeviceType.sensor,
    IotDeviceType.switch_,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _clearNameError() {
    if (_nameError != null) {
      setState(() => _nameError = null);
    }
  }

  void _submit(final BuildContext context) {
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = widget.l10n.iotDemoAddDeviceNameRequired);
      return;
    }
    if (name.length > iotDemoDeviceNameMaxLength) {
      setState(
        () => _nameError = widget.l10n.iotDemoAddDeviceNameTooLong(
          iotDemoDeviceNameMaxLength.toString(),
        ),
      );
      return;
    }
    final bool hasValue =
        _selectedType == IotDeviceType.thermostat ||
        _selectedType == IotDeviceType.sensor;
    final double value = hasValue
        ? iotDemoClampAndRound(
            _initialValue,
            iotDemoValueMin,
            iotDemoValueMax,
          )
        : 0.0;
    NavigationUtils.maybePop(
      context,
      result: IotDemoAddDeviceResult(
        name: name,
        type: _selectedType,
        initialValue: value,
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = widget.l10n;
    final cancelLabel = l10n.cancelButtonLabel;
    final okLabel = MaterialLocalizations.of(context).okButtonLabel;
    final useCupertino = PlatformAdaptive.isCupertinoFromTheme(
      Theme.of(context),
    );
    final hasValue =
        _selectedType == IotDeviceType.thermostat ||
        _selectedType == IotDeviceType.sensor;

    return useCupertino
        ? _buildCupertinoDialog(context, l10n, cancelLabel, okLabel, hasValue)
        : _buildMaterialDialog(context, l10n, cancelLabel, okLabel, hasValue);
  }

  Widget _buildMaterialDialog(
    final BuildContext context,
    final AppLocalizations l10n,
    final String cancelLabel,
    final String okLabel,
    final bool hasValue,
  ) => AlertDialog(
    title: Text(l10n.iotDemoAddDevice),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: _nameController,
            maxLength: iotDemoDeviceNameMaxLength,
            decoration: InputDecoration(
              labelText: l10n.iotDemoAddDeviceNameHint,
              errorText: _nameError,
            ),
            onChanged: (_) => _clearNameError(),
            onSubmitted: (_) => _submit(context),
          ),
          SizedBox(height: context.responsiveGapM),
          DropdownButtonFormField<IotDeviceType>(
            // ignore: deprecated_member_use - DropdownButtonFormField still uses value
            value: _selectedType,
            decoration: InputDecoration(
              labelText: l10n.iotDemoAddDeviceTypeHint,
            ),
            items: _types
                .map(
                  (final t) => DropdownMenuItem<IotDeviceType>(
                    value: t,
                    child: Text(iotDemoDeviceTypeLabel(t, widget.l10n)),
                  ),
                )
                .toList(),
            onChanged: (final t) {
              if (t != null) setState(() => _selectedType = t);
            },
          ),
          if (hasValue) ...[
            SizedBox(height: context.responsiveGapM),
            Semantics(
              label: l10n.iotDemoAddDeviceInitialValue(
                _initialValue.toString(),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Slider.adaptive(
                    value: _initialValue.clamp(
                      iotDemoValueMin,
                      iotDemoValueMax,
                    ),
                    max: iotDemoValueMax,
                    label: _initialValue.toStringAsFixed(0),
                    onChanged: (final v) => setState(() => _initialValue = v),
                  ),
                  ExcludeSemantics(
                    child: Text(
                      l10n.iotDemoAddDeviceInitialValue(
                        _initialValue.toString(),
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
    actions: <Widget>[
      PlatformAdaptive.dialogAction(
        context: context,
        onPressed: () => NavigationUtils.maybePop(context),
        label: cancelLabel,
      ),
      PlatformAdaptive.dialogAction(
        context: context,
        onPressed: () => _submit(context),
        label: okLabel,
      ),
    ],
  );

  Widget _buildCupertinoDialog(
    final BuildContext context,
    final AppLocalizations l10n,
    final String cancelLabel,
    final String okLabel,
    final bool hasValue,
  ) => CupertinoAlertDialog(
    title: Text(l10n.iotDemoAddDevice),
    content: Builder(
      builder: (final _) => Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: EdgeInsets.only(top: context.responsiveGapM),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CupertinoTextField(
                controller: _nameController,
                placeholder: l10n.iotDemoAddDeviceNameHint,
                maxLength: iotDemoDeviceNameMaxLength,
                onChanged: (_) => _clearNameError(),
                onSubmitted: (_) => _submit(context),
              ),
              if (_nameError case final String err?) ...[
                SizedBox(height: context.responsiveGapXS),
                Text(
                  err,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
              SizedBox(height: context.responsiveGapM),
              DropdownButtonFormField<IotDeviceType>(
                // ignore: deprecated_member_use - DropdownButtonFormField still uses value
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: l10n.iotDemoAddDeviceTypeHint,
                ),
                items: _types
                    .map(
                      (final t) => DropdownMenuItem<IotDeviceType>(
                        value: t,
                        child: Text(iotDemoDeviceTypeLabel(t, widget.l10n)),
                      ),
                    )
                    .toList(),
                onChanged: (final t) {
                  if (t != null) setState(() => _selectedType = t);
                },
              ),
              if (hasValue) ...[
                SizedBox(height: context.responsiveGapM),
                Semantics(
                  label: l10n.iotDemoAddDeviceInitialValue(
                    _initialValue.toString(),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Slider.adaptive(
                        value: _initialValue.clamp(
                          iotDemoValueMin,
                          iotDemoValueMax,
                        ),
                        max: iotDemoValueMax,
                        onChanged: (final v) =>
                            setState(() => _initialValue = v),
                      ),
                      ExcludeSemantics(
                        child: Text(
                          l10n.iotDemoAddDeviceInitialValue(
                            _initialValue.toString(),
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
    actions: <CupertinoDialogAction>[
      CupertinoDialogAction(
        onPressed: () => NavigationUtils.maybePop(context),
        child: Text(cancelLabel),
      ),
      CupertinoDialogAction(
        onPressed: () => _submit(context),
        child: Text(okLabel),
      ),
    ],
  );
}
