part of 'platform_adaptive.dart';

/// Helpers to keep platform-adaptive branching consistent across the app.
class PlatformAdaptive {
  const PlatformAdaptive._();

  static bool isCupertino(BuildContext context) =>
      isCupertinoFromTheme(Theme.of(context));

  static bool isCupertinoFromTheme(ThemeData theme) =>
      isCupertinoPlatform(theme.platform);

  static bool isCupertinoPlatform(TargetPlatform platform) =>
      platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

  /// Returns a platform-adaptive button widget
  /// Uses CupertinoButton on iOS/macOS, Material button elsewhere
  static Widget button({
    required BuildContext context,
    required VoidCallback? onPressed,
    required Widget child,
    EdgeInsetsGeometry? padding,
    Color? color,
    Color? disabledColor,
    double? minSize,
    double? pressedOpacity,
    BorderRadius? borderRadius,
    ButtonStyle? materialStyle,
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
    required BuildContext context,
    required VoidCallback? onPressed,
    required Widget child,
    EdgeInsetsGeometry? padding,
    Color? color,
    Color? disabledColor,
    ButtonStyle? materialStyle,
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
    required BuildContext context,
    required VoidCallback? onPressed,
    required Widget child,
    Key? key,
    EdgeInsetsGeometry? padding,
    Color? color,
    Color? disabledColor,
    ButtonStyle? materialStyle,
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
    required BuildContext context,
    required VoidCallback? onPressed,
    required Widget child,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? disabledColor,
    BorderSide? side,
    BorderRadius? borderRadius,
    ButtonStyle? materialStyle,
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
    required BuildContext context,
    required VoidCallback? onPressed,
    required String label,
    bool isDestructive = false,
  }) => PlatformAdaptiveButtons.dialogAction(
    context: context,
    onPressed: onPressed,
    label: label,
    isDestructive: isDestructive,
  );

  /// Returns a platform-adaptive text field widget
  /// Uses CupertinoTextField on iOS/macOS, TextField elsewhere
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
    required BuildContext context,
    required bool? value,
    required ValueChanged<bool?>? onChanged,
    Color? activeColor,
    Color? checkColor,
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
    required BuildContext context,
    required Widget title,
    Widget? subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
    bool selected = false,
    Color? selectedTileColor,
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
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = false,
    Color? backgroundColor,
    bool useSafeArea = false,
    bool isDismissible = true,
    bool enableDrag = true,
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
    required BuildContext context,
    required List<T> items,
    required T selectedItem,
    required String Function(T) itemLabel,
    Object Function(T item)? itemKey,
    String? title,
    Widget Function(BuildContext, T)? itemBuilder,
    String cancelLabel = 'Cancel',
    String doneLabel = 'Done',
  }) {
    if (PlatformAdaptive.isCupertino(context)) {
      return showCupertinoModalPopup<T>(
        context: context,
        builder: (popupContext) => _CupertinoPickerSheetContent<T>(
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
      builder: (sheetContext) => _MaterialPickerSheetContent<T>(
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
  Widget build(BuildContext context) {
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
              itemBuilder: (itemContext, index) {
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
  Widget build(BuildContext context) {
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
                onSelectedItemChanged: (index) {
                  if (index >= 0 && index < widget.items.length) {
                    setState(() {
                      _currentSelection = widget.items[index];
                    });
                  }
                },
                children: widget.items.map((item) {
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
