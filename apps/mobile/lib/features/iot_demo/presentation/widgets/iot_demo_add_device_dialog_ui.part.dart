// Split helper extension owns UI callbacks and State.setState for this dialog.
// ignore_for_file: avoid_positional_boolean_parameters, invalid_use_of_protected_member

part of 'iot_demo_add_device_dialog.dart';

extension _IotDemoAddDeviceDialogUi on _IotDemoAddDeviceDialogBodyState {
  Widget buildMaterialDialog(
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
            items: _iotDemoAddDeviceDialogTypes
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

  Widget buildCupertinoDialog(
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
                items: _iotDemoAddDeviceDialogTypes
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
