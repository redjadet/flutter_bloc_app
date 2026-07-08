import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';

/// App-local search field with default l10n hint text.
class CommonSearchField extends StatelessWidget {
  const CommonSearchField({
    required this.controller,
    super.key,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String? hintText;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final bool enabled;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonFormField(
      controller: controller,
      hintText: hintText ?? l10n.searchHint,
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
}
