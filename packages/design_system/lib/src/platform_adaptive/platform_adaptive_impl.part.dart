part of 'platform_adaptive.dart';

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
    final FocusNode? focusNode,
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
    focusNode: focusNode,
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
  }) {
    if (PlatformAdaptive.isCupertino(context)) {
      return showCupertinoModalPopup<T>(context: context, builder: builder);
    }
    return showModalBottomSheet<T>(
      context: context,
      builder: builder,
      isScrollControlled: isScrollControlled,
      backgroundColor: backgroundColor,
      useSafeArea: useSafeArea,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
    );
  }

  /// Shows a platform-adaptive picker modal for selecting from a list of items
  /// On iOS/macOS: Shows CupertinoPicker in a CupertinoActionSheet
  /// On Android: Shows a bottom sheet with a list
  static Future<T?> showPickerModal<T>({
    required final BuildContext context,
    required final List<T> items,
    required final T selectedItem,
    required final String Function(T) itemLabel,
    final Object Function(T item)? itemKey,
    final String? title,
    final Widget Function(BuildContext, T)? itemBuilder,
    final String cancelLabel = 'Cancel',
    final String doneLabel = 'Done',
  }) {
    if (PlatformAdaptive.isCupertino(context)) {
      return showCupertinoModalPopup<T>(
        context: context,
        builder: (final popupContext) => _CupertinoPickerSheetContent<T>(
          items: items,
          selectedItem: selectedItem,
          title: title,
          itemLabel: itemLabel,
          itemKey: itemKey,
          itemBuilder: itemBuilder,
          cancelLabel: cancelLabel,
          doneLabel: doneLabel,
        ),
      );
    }

    return showModalBottomSheet<T>(
      context: context,
      builder: (final sheetContext) => _MaterialPickerSheetContent<T>(
        items: items,
        selectedItem: selectedItem,
        itemLabel: itemLabel,
        itemKey: itemKey,
        title: title,
        itemBuilder: itemBuilder,
      ),
    );
  }
}

class _MaterialPickerSheetContent<T> extends StatelessWidget {
  const _MaterialPickerSheetContent({
    required this.items,
    required this.selectedItem,
    required this.itemLabel,
    required this.itemKey,
    this.title,
    this.itemBuilder,
  });

  final List<T> items;
  final T selectedItem;
  final String Function(T) itemLabel;
  final Object Function(T item)? itemKey;
  final String? title;
  final Widget Function(BuildContext, T)? itemBuilder;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (title case final resolvedTitle?)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                resolvedTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (final itemContext, final index) {
                final T item = items[index];
                final Object? keyValue = itemKey?.call(item) ?? item;
                return ListTile(
                  key: ValueKey<Object?>(keyValue),
                  title: switch (itemBuilder) {
                    final Widget Function(BuildContext, T) builder => builder(
                      context,
                      item,
                    ),
                    _ => Text(itemLabel(item)),
                  },
                  trailing: item == selectedItem
                      ? Icon(Icons.check, color: theme.colorScheme.primary)
                      : null,
                  onTap: () => Navigator.of(context).pop(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CupertinoPickerSheetContent<T> extends StatefulWidget {
  const _CupertinoPickerSheetContent({
    required this.items,
    required this.selectedItem,
    required this.itemLabel,
    required this.cancelLabel,
    required this.doneLabel,
    required this.itemKey,
    this.title,
    this.itemBuilder,
  });

  final List<T> items;
  final T selectedItem;
  final String? title;
  final String Function(T) itemLabel;
  final Object Function(T item)? itemKey;
  final Widget Function(BuildContext, T)? itemBuilder;
  final String cancelLabel;
  final String doneLabel;

  @override
  State<_CupertinoPickerSheetContent<T>> createState() =>
      _CupertinoPickerSheetContentState<T>();
}

class _CupertinoPickerSheetContentState<T>
    extends State<_CupertinoPickerSheetContent<T>> {
  late final FixedExtentScrollController _scrollController;
  late T _currentSelection;

  @override
  void initState() {
    super.initState();
    final int selectedIndex = widget.items.indexOf(widget.selectedItem);
    _scrollController = FixedExtentScrollController(
      initialItem: selectedIndex >= 0 ? selectedIndex : 0,
    );
    _currentSelection = widget.selectedItem;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 260,
      padding: const EdgeInsets.only(top: 6),
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            if (widget.title case final t?)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(t, style: theme.textTheme.titleMedium),
              ),
            Expanded(
              child: CupertinoPicker(
                scrollController: _scrollController,
                itemExtent: 32,
                onSelectedItemChanged: (final index) {
                  if (index >= 0 && index < widget.items.length) {
                    setState(() {
                      _currentSelection = widget.items[index];
                    });
                  }
                },
                children: widget.items.map((final item) {
                  final Object? keyValue = widget.itemKey?.call(item) ?? item;
                  return KeyedSubtree(
                    key: ValueKey<Object?>(keyValue),
                    child: Center(
                      child: switch (widget.itemBuilder) {
                        final fn? => fn(context, item),
                        _ => Text(widget.itemLabel(item)),
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                CupertinoButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(widget.cancelLabel),
                ),
                CupertinoButton(
                  onPressed: () => Navigator.of(context).pop(_currentSelection),
                  child: Text(widget.doneLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
