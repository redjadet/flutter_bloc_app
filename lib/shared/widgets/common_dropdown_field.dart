import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_input_decoration_helpers.dart';

/// Label position for CommonDropdownField
enum DropdownLabelPosition {
  /// Label appears above the dropdown field
  top,

  /// Label appears to the left of the dropdown field (in a Row)
  left,
}

/// A reusable dropdown field with consistent styling
/// Platform-adaptive: Uses CupertinoPicker modal on iOS/macOS, DropdownButtonFormField on Android
class CommonDropdownField<T> extends StatelessWidget {
  const CommonDropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
    super.key,
    this.labelText,
    this.hintText,
    this.validator,
    this.enabled = true,
    this.isExpanded = true,
    this.labelPosition = DropdownLabelPosition.top,
    this.customItemLabel,
    this.customPickerItems,
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? labelText;
  final String? hintText;
  final String? Function(T?)? validator;
  final bool enabled;
  final bool isExpanded;
  final DropdownLabelPosition labelPosition;
  final String Function(T)? customItemLabel;
  final List<T>? customPickerItems;

  // Extract all values from DropdownMenuItem list (filters out nulls)
  // Use customPickerItems if provided, otherwise extract from items
  List<T> _getPickerValues() {
    if (customPickerItems != null) {
      return customPickerItems!;
    }
    return items.map((final item) => item.value).whereType<T>().toList();
  }

  // Extract label text from DropdownMenuItem child widget (for picker items)
  String _getItemLabel(final T itemValue) {
    if (customItemLabel != null) {
      return customItemLabel!(itemValue);
    }

    final item = items.firstWhere(
      (final item) => item.value == itemValue,
      orElse: () => items.first,
    );
    final child = item.child;
    if (child is Text) {
      return child.data ?? itemValue.toString();
    }
    return itemValue.toString();
  }

  // Extract label text for the selected value (for display)
  String _getSelectedLabel() {
    if (value == null) {
      // For null value, try to get label from first item with null value, or use hintText/labelText
      final nullItem = items
          .where((final item) => item.value == null)
          .firstOrNull;
      if (nullItem != null) {
        final child = nullItem.child;
        if (child is Text) {
          return child.data ?? (hintText ?? labelText ?? '');
        }
      }
      return hintText ?? labelText ?? '';
    }

    if (customItemLabel != null) {
      return customItemLabel!(value as T);
    }

    final item = items.firstWhere(
      (final item) => item.value == value,
      orElse: () => items.first,
    );
    final child = item.child;
    if (child is Text) {
      return child.data ?? (value?.toString() ?? '');
    }
    return value?.toString() ?? '';
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final isCupertino = PlatformAdaptive.isCupertino(context);

    if (isCupertino) {
      final List<T> pickerValues = _getPickerValues();
      final String selectedLabel = _getSelectedLabel();

      final Widget pickerField = GestureDetector(
        onTap: enabled && pickerValues.isNotEmpty
            ? () async {
                // Use first item as default if value is null
                final T defaultItem = value != null
                    ? (value as T)
                    : pickerValues.first;
                final T? result = await PlatformAdaptive.showPickerModal<T>(
                  context: context,
                  items: pickerValues,
                  selectedItem: defaultItem,
                  itemLabel: _getItemLabel,
                  title: labelText,
                );
                if (result != value && context.mounted) {
                  onChanged?.call(result);
                }
              }
            : null,
        child: Container(
          padding: EdgeInsets.all(context.responsiveGapS),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(context.responsiveCardRadius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  selectedLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: value != null
                        ? null
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(
                CupertinoIcons.chevron_down,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      );

      if (labelPosition == DropdownLabelPosition.left) {
        // Row layout with label on left
        return Row(
          children: [
            if (labelText != null) ...[
              Text(labelText!, style: theme.textTheme.titleMedium),
              SizedBox(width: context.responsiveHorizontalGapS),
            ],
            Expanded(child: pickerField),
          ],
        );
      }

      // Column layout with label on top (default)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (labelText != null) ...[
            Text(
              labelText!,
              style: theme.textTheme.labelMedium,
            ),
            SizedBox(height: context.responsiveGapS),
          ],
          pickerField,
        ],
      );
    }

    return DropdownButtonFormField<T>(
      key: value != null ? ValueKey(value) : null,
      initialValue: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      isExpanded: isExpanded,
      decoration: buildCommonInputDecoration(
        context: context,
        theme: theme,
        labelText: labelText,
        hintText: hintText,
        includeErrorBorders: false,
      ),
    );
  }
}
