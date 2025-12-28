import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

InputDecoration _buildCommonInputDecoration({
  required final BuildContext context,
  required final ThemeData theme,
  final String? labelText,
  final String? hintText,
  final String? helperText,
  final String? errorText,
  final Widget? prefixIcon,
  final Widget? suffixIcon,
  final bool includeErrorBorders = true,
}) {
  final borderRadius = BorderRadius.circular(context.responsiveCardRadius);
  final baseDecoration = InputDecoration(
    labelText: labelText,
    hintText: hintText,
    helperText: helperText,
    errorText: errorText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    border: OutlineInputBorder(borderRadius: borderRadius),
    enabledBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(
        color: theme.colorScheme.outline.withValues(alpha: 0.5),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
    ),
    contentPadding: EdgeInsets.symmetric(
      horizontal: context.responsiveHorizontalGapL,
      vertical: context.responsiveGapM,
    ),
  );

  if (!includeErrorBorders) {
    return baseDecoration;
  }

  return baseDecoration.copyWith(
    errorBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: theme.colorScheme.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
    ),
  );
}

/// A reusable form field with consistent styling and validation
class CommonFormField extends StatelessWidget {
  const CommonFormField({
    required this.controller,
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool autofocus;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      autofocus: autofocus,
      decoration: _buildCommonInputDecoration(
        context: context,
        theme: theme,
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

/// A reusable search field with common search functionality
class CommonSearchField extends StatelessWidget {
  const CommonSearchField({
    required this.controller,
    super.key,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String hintText;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final bool enabled;

  @override
  Widget build(final BuildContext context) => CommonFormField(
    controller: controller,
    hintText: hintText,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    enabled: enabled,
    prefixIcon: const Icon(Icons.search),
    suffixIcon: controller.text.isNotEmpty
        ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              controller.clear();
              onClear?.call();
            },
          )
        : null,
  );
}

/// A reusable dropdown field with consistent styling
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
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? labelText;
  final String? hintText;
  final String? Function(T?)? validator;
  final bool enabled;
  final bool isExpanded;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      isExpanded: isExpanded,
      decoration: _buildCommonInputDecoration(
        context: context,
        theme: theme,
        labelText: labelText,
        hintText: hintText,
        includeErrorBorders: false,
      ),
    );
  }
}
