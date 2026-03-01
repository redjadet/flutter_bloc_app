import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/design_system/app_styles.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/navigation.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:mix/mix.dart';

class PlatformAdaptiveSheets {
  const PlatformAdaptiveSheets._();

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
      return showCupertinoModalPopup<T>(
        context: context,
        builder: builder,
      );
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

  static Future<T?> showPickerModal<T>({
    required final BuildContext context,
    required final List<T> items,
    required final T selectedItem,
    required final String Function(T) itemLabel,
    final String? title,
    final Widget Function(BuildContext, T)? itemBuilder,
  }) async {
    if (PlatformAdaptive.isCupertino(context)) {
      return showCupertinoModalPopup<T>(
        context: context,
        builder: (final popupContext) => _CupertinoPickerSheetContent<T>(
          items: items,
          selectedItem: selectedItem,
          title: title,
          itemLabel: itemLabel,
          itemBuilder: itemBuilder,
          onDone: (final result) =>
              NavigationUtils.maybePop(popupContext, result: result),
          onCancel: () => NavigationUtils.maybePop(popupContext),
        ),
      );
    }

    return showModalBottomSheet<T>(
      context: context,
      builder: (final sheetContext) {
        final theme = Theme.of(sheetContext);
        final double titleBottomGap = sheetContext.responsiveGapM;
        return SafeArea(
          child: Box(
            style: AppStyles.dialogContent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title case final resolvedTitle?)
                  Padding(
                    padding: EdgeInsets.only(bottom: titleBottomGap),
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
                    itemBuilder: (final context, final index) {
                      final item = items[index];
                      final isSelected = item == selectedItem;
                      return ListTile(
                        title: itemBuilder != null
                            ? itemBuilder(context, item)
                            : Text(itemLabel(item)),
                        trailing: isSelected
                            ? Icon(
                                Icons.check,
                                color: theme.colorScheme.primary,
                              )
                            : null,
                        onTap: () => NavigationUtils.maybePop(
                          sheetContext,
                          result: item,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Stateful widget that owns `FixedExtentScrollController` for `CupertinoPicker`.
///
/// Controllers must be created in initState and disposed in dispose per
/// Flutter ownership rules.
class _CupertinoPickerSheetContent<T> extends StatefulWidget {
  const _CupertinoPickerSheetContent({
    required this.items,
    required this.selectedItem,
    required this.itemLabel,
    required this.onDone,
    required this.onCancel,
    this.title,
    this.itemBuilder,
  });

  final List<T> items;
  final T selectedItem;
  final String? title;
  final String Function(T) itemLabel;
  final Widget Function(BuildContext, T)? itemBuilder;
  final void Function(T result) onDone;
  final VoidCallback onCancel;

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
      height: 250,
      padding: const EdgeInsets.only(top: 6),
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            if (widget.title case final t?)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  t,
                  style: theme.textTheme.titleMedium,
                ),
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
                children: widget.items
                    .map(
                      (final item) => Center(
                        child: switch (widget.itemBuilder) {
                          final fn? => fn(context, item),
                          _ => Text(widget.itemLabel(item)),
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancel'),
                ),
                CupertinoButton(
                  onPressed: () => widget.onDone(_currentSelection),
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
