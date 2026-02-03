import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

class PlatformAdaptiveInputs {
  const PlatformAdaptiveInputs._();

  static Widget textField({
    required final BuildContext context,
    required final TextEditingController controller,
    final String? placeholder,
    final String? hintText,
    final void Function(String)? onChanged,
    final void Function(String)? onSubmitted,
    final TextInputType? keyboardType,
    final bool obscureText = false,
    final int? maxLines = 1,
    final bool enabled = true,
    final bool autofocus = false,
    final EdgeInsetsGeometry? padding,
    final InputDecoration? decoration,
    final TextStyle? style,
  }) {
    if (PlatformAdaptive.isCupertino(context)) {
      return CupertinoTextField(
        controller: controller,
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
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      enabled: enabled,
      autofocus: autofocus,
      style: style,
      decoration:
          decoration ??
          InputDecoration(
            hintText: hintText ?? placeholder,
          ),
    );
  }

  static Widget checkbox({
    required final BuildContext context,
    required final bool? value,
    required final ValueChanged<bool?>? onChanged,
    final Color? activeColor,
    final Color? checkColor,
  }) {
    if (PlatformAdaptive.isCupertino(context)) {
      final theme = Theme.of(context);
      return CupertinoCheckbox(
        value: value ?? false,
        onChanged: onChanged != null
            ? (final newValue) => onChanged(newValue)
            : null,
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
    required final BuildContext context,
    required final Widget title,
    final Widget? subtitle,
    final Widget? leading,
    final Widget? trailing,
    final VoidCallback? onTap,
    final bool selected = false,
    final Color? selectedTileColor,
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
