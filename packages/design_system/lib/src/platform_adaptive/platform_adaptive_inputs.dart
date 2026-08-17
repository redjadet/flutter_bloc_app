import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'platform_adaptive.dart';

class PlatformAdaptiveInputs {
  const PlatformAdaptiveInputs._();

  static Widget textField({
    required BuildContext context,
    required TextEditingController controller,
    FocusNode? focusNode,
    String? placeholder,
    String? hintText,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    TextInputType? keyboardType,
    bool obscureText = false,
    int? maxLines = 1,
    bool enabled = true,
    bool autofocus = false,
    EdgeInsetsGeometry? padding,
    InputDecoration? decoration,
    TextStyle? style,
  }) {
    if (PlatformAdaptive.isCupertino(context)) {
      return CupertinoTextField(
        controller: controller,
        focusNode: focusNode,
        placeholder: placeholder ?? hintText,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: maxLines,
        enabled: enabled,
        autofocus: autofocus,
        padding: padding ?? EdgeInsets.zero,
        style: style,
      );
    }
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      enabled: enabled,
      autofocus: autofocus,
      style: style,
      decoration:
          decoration ?? InputDecoration(hintText: hintText ?? placeholder),
    );
  }

  static Widget checkbox({
    required BuildContext context,
    required bool? value,
    required ValueChanged<bool?>? onChanged,
    Color? activeColor,
    Color? checkColor,
  }) {
    if (PlatformAdaptive.isCupertino(context)) {
      final theme = Theme.of(context);
      return CupertinoCheckbox(
        value: value ?? false,
        onChanged: onChanged != null ? (newValue) => onChanged(newValue) : null,
        activeColor: activeColor ?? theme.colorScheme.primary,
      );
    }
    return Checkbox(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor,
      checkColor: checkColor,
      tristate: value == null,
    );
  }

  static Widget listTile({
    required BuildContext context,
    required Widget title,
    Widget? subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
    bool selected = false,
    Color? selectedTileColor,
  }) {
    if (PlatformAdaptive.isCupertino(context)) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      return CupertinoListTile(
        title: title,
        subtitle: subtitle,
        leading: leading,
        trailing: trailing,
        onTap: onTap,
        backgroundColor: selected
            ? (selectedTileColor ??
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.5))
            : null,
        backgroundColorActivated:
            selectedTileColor ??
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      );
    }
    return ListTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
      onTap: onTap,
      selected: selected,
      selectedTileColor: selectedTileColor,
    );
  }
}
