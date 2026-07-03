import 'package:flutter/material.dart';

import 'common_input_decoration_helpers.dart';

/// A reusable form field with consistent styling and validation.
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
    this.autofillHints,
    this.autocorrect = true,
    this.enableSuggestions = true,
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
  final Iterable<String>? autofillHints;
  final bool autocorrect;
  final bool enableSuggestions;
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
      autofillHints: autofillHints,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      enabled: enabled,
      autofocus: autofocus,
      decoration: buildCommonInputDecoration(
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
