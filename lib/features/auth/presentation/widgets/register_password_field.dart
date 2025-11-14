import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

class RegisterPasswordField extends StatefulWidget {
  const RegisterPasswordField({
    required this.hint,
    required this.errorText,
    required this.value,
    required this.onChanged,
    required this.textStyle,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    super.key,
  });

  final String hint;
  final String? errorText;
  final String value;
  final ValueChanged<String> onChanged;
  final TextStyle textStyle;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<RegisterPasswordField> createState() => _RegisterPasswordFieldState();
}

class _RegisterPasswordFieldState extends State<RegisterPasswordField> {
  late final TextEditingController _controller;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(final RegisterPasswordField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return TextFormField(
      controller: _controller,
      obscureText: _obscure,
      style: widget.textStyle,
      cursorColor: colorScheme.primary,
      keyboardAppearance: theme.brightness == Brightness.dark
          ? Brightness.dark
          : Brightness.light,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        errorText: widget.errorText,
        filled: true,
        fillColor: Color.alphaBlend(
          colorScheme.onSurface.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.16 : 0.04,
          ),
          colorScheme.surface,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.responsiveCardRadius),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.4),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.responsiveCardRadius),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.responsiveCardRadius),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.5,
          ),
        ),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(
            _obscure ? Icons.visibility_off : Icons.visibility,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
    );
  }
}
