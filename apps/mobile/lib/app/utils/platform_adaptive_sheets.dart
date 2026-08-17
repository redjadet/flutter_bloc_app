import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/utils/navigation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mix/mix.dart';

part 'platform_adaptive_sheets.part.dart';

/// Platform-adaptive bottom sheets and action dialogs (Cupertino vs Material).
class PlatformAdaptiveSheets {
  const PlatformAdaptiveSheets._();

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
    required BuildContext context,
    required List<T> items,
    required T selectedItem,
    required String Function(T) itemLabel,
    Object Function(T item)? itemKey,
    String? title,
    Widget Function(BuildContext, T)? itemBuilder,
  }) async {
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
          onDone: (result) =>
              NavigationUtils.maybePop(popupContext, result: result),
          onCancel: () => NavigationUtils.maybePop(popupContext),
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
