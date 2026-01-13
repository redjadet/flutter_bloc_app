import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/utils/navigation.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

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
      T currentSelection = selectedItem;
      return showCupertinoModalPopup<T>(
        context: context,
        builder: (final popupContext) => StatefulBuilder(
          builder: (final context, final setState) {
            final theme = Theme.of(context);
            final selectedIndex = items.indexOf(selectedItem);

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
                    if (title != null)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          title,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedIndex >= 0 ? selectedIndex : 0,
                        ),
                        itemExtent: 32,
                        onSelectedItemChanged: (final int index) {
                          setState(() {
                            currentSelection = items[index];
                          });
                        },
                        children: items
                            .map(
                              (final item) => Center(
                                child: itemBuilder != null
                                    ? itemBuilder(context, item)
                                    : Text(itemLabel(item)),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CupertinoButton(
                          onPressed: () =>
                              NavigationUtils.maybePop(popupContext),
                          child: const Text('Cancel'),
                        ),
                        CupertinoButton(
                          onPressed: () => NavigationUtils.maybePop(
                            popupContext,
                            result: currentSelection,
                          ),
                          child: const Text('Done'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    return showModalBottomSheet<T>(
      context: context,
      builder: (final sheetContext) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    title,
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
                      onTap: () =>
                          NavigationUtils.maybePop(sheetContext, result: item),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
