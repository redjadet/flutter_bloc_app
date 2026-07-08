import 'package:design_system/design_system.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/utils/navigation.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_value_range.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/widgets/iot_demo_device_type_label.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

part 'iot_demo_add_device_dialog_helpers.part.dart';
part 'iot_demo_add_device_dialog_models.part.dart';
part 'iot_demo_add_device_dialog_ui.part.dart';

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
        ? buildCupertinoDialog(context, l10n, cancelLabel, okLabel, hasValue)
        : buildMaterialDialog(context, l10n, cancelLabel, okLabel, hasValue);
  }
}
