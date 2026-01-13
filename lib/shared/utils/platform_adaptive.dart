import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive_buttons.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive_inputs.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive_sheets.dart';

/// Helpers to keep platform-adaptive branching consistent across the app.
class PlatformAdaptive {
  const PlatformAdaptive._();

  static bool isCupertino(final BuildContext context) =>
      isCupertinoFromTheme(Theme.of(context));

  static bool isCupertinoFromTheme(final ThemeData theme) =>
      isCupertinoPlatform(theme.platform);

  static bool isCupertinoPlatform(final TargetPlatform platform) =>
      platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

  /// Returns a platform-adaptive button widget
  /// Uses CupertinoButton on iOS/macOS, Material button elsewhere
  static Widget button({
    required final BuildContext context,
    required final VoidCallback? onPressed,
    required final Widget child,
    final EdgeInsetsGeometry? padding,
    final Color? color,
    final Color? disabledColor,
    final double? minSize,
    final double? pressedOpacity,
    final BorderRadius? borderRadius,
    final ButtonStyle? materialStyle,
  }) => PlatformAdaptiveButtons.button(
    context: context,
    onPressed: onPressed,
    child: child,
    padding: padding,
    color: color,
    disabledColor: disabledColor,
    minSize: minSize,
    pressedOpacity: pressedOpacity,
    borderRadius: borderRadius,
    materialStyle: materialStyle,
  );

  /// Returns a platform-adaptive text button widget
  static Widget textButton({
    required final BuildContext context,
    required final VoidCallback? onPressed,
    required final Widget child,
    final EdgeInsetsGeometry? padding,
    final Color? color,
    final Color? disabledColor,
    final ButtonStyle? materialStyle,
  }) => PlatformAdaptiveButtons.textButton(
    context: context,
    onPressed: onPressed,
    child: child,
    padding: padding,
    color: color,
    disabledColor: disabledColor,
    materialStyle: materialStyle,
  );

  /// Returns a platform-adaptive filled button widget
  static Widget filledButton({
    required final BuildContext context,
    required final VoidCallback? onPressed,
    required final Widget child,
    final Key? key,
    final EdgeInsetsGeometry? padding,
    final Color? color,
    final Color? disabledColor,
    final ButtonStyle? materialStyle,
  }) => PlatformAdaptiveButtons.filledButton(
    context: context,
    onPressed: onPressed,
    child: child,
    key: key,
    padding: padding,
    color: color,
    disabledColor: disabledColor,
    materialStyle: materialStyle,
  );

  /// Returns a platform-adaptive outlined button widget.
  static Widget outlinedButton({
    required final BuildContext context,
    required final VoidCallback? onPressed,
    required final Widget child,
    final EdgeInsetsGeometry? padding,
    final Color? backgroundColor,
    final Color? foregroundColor,
    final Color? disabledColor,
    final BorderSide? side,
    final BorderRadius? borderRadius,
    final ButtonStyle? materialStyle,
  }) => PlatformAdaptiveButtons.outlinedButton(
    context: context,
    onPressed: onPressed,
    child: child,
    padding: padding,
    backgroundColor: backgroundColor,
    foregroundColor: foregroundColor,
    disabledColor: disabledColor,
    side: side,
    borderRadius: borderRadius,
    materialStyle: materialStyle,
  );

  /// Returns a platform-adaptive dialog action button
  static Widget dialogAction({
    required final BuildContext context,
    required final VoidCallback? onPressed,
    required final String label,
    final bool isDestructive = false,
  }) => PlatformAdaptiveButtons.dialogAction(
    context: context,
    onPressed: onPressed,
    label: label,
    isDestructive: isDestructive,
  );

  /// Returns a platform-adaptive text field widget
  /// Uses CupertinoTextField on iOS/macOS, TextField elsewhere
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
  }) => PlatformAdaptiveInputs.textField(
    context: context,
    controller: controller,
    placeholder: placeholder,
    hintText: hintText,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    keyboardType: keyboardType,
    obscureText: obscureText,
    maxLines: maxLines,
    enabled: enabled,
    autofocus: autofocus,
    padding: padding,
    decoration: decoration,
    style: style,
  );

  /// Returns a platform-adaptive checkbox widget
  /// Uses CupertinoCheckbox on iOS/macOS, Checkbox elsewhere
  static Widget checkbox({
    required final BuildContext context,
    required final bool? value,
    required final ValueChanged<bool?>? onChanged,
    final Color? activeColor,
    final Color? checkColor,
  }) => PlatformAdaptiveInputs.checkbox(
    context: context,
    value: value,
    onChanged: onChanged,
    activeColor: activeColor,
    checkColor: checkColor,
  );

  /// Returns a platform-adaptive list tile widget
  /// Uses CupertinoListTile on iOS/macOS, ListTile elsewhere
  static Widget listTile({
    required final BuildContext context,
    required final Widget title,
    final Widget? subtitle,
    final Widget? leading,
    final Widget? trailing,
    final VoidCallback? onTap,
    final bool selected = false,
    final Color? selectedTileColor,
  }) => PlatformAdaptiveInputs.listTile(
    context: context,
    title: title,
    subtitle: subtitle,
    leading: leading,
    trailing: trailing,
    onTap: onTap,
    selected: selected,
    selectedTileColor: selectedTileColor,
  );

  /// Shows a platform-adaptive modal bottom sheet
  /// Uses CupertinoActionSheet on iOS/macOS, Material showModalBottomSheet elsewhere
  static Future<T?> showAdaptiveModalBottomSheet<T>({
    required final BuildContext context,
    required final WidgetBuilder builder,
    final bool isScrollControlled = false,
    final Color? backgroundColor,
    final bool useSafeArea = false,
    final bool isDismissible = true,
    final bool enableDrag = true,
  }) => PlatformAdaptiveSheets.showAdaptiveModalBottomSheet(
    context: context,
    builder: builder,
    isScrollControlled: isScrollControlled,
    backgroundColor: backgroundColor,
    useSafeArea: useSafeArea,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
  );

  /// Shows a platform-adaptive picker modal for selecting from a list of items
  /// On iOS/macOS: Shows CupertinoPicker in a CupertinoActionSheet
  /// On Android: Shows a bottom sheet with a list
  static Future<T?> showPickerModal<T>({
    required final BuildContext context,
    required final List<T> items,
    required final T selectedItem,
    required final String Function(T) itemLabel,
    final String? title,
    final Widget Function(BuildContext, T)? itemBuilder,
  }) => PlatformAdaptiveSheets.showPickerModal(
    context: context,
    items: items,
    selectedItem: selectedItem,
    itemLabel: itemLabel,
    title: title,
    itemBuilder: itemBuilder,
  );
}
