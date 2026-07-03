import 'package:design_system/design_system.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/design_system/app_styles.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/navigation.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:mix/mix.dart';

part 'platform_adaptive_sheets.part.dart';

/// Platform-adaptive bottom sheets and action dialogs (Cupertino vs Material).
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
    final Object Function(T item)? itemKey,
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
          itemKey: itemKey,
          itemBuilder: itemBuilder,
          onDone: (final result) =>
              NavigationUtils.maybePop(popupContext, result: result),
          onCancel: () => NavigationUtils.maybePop(popupContext),
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
