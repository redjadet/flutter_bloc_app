import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

TextStyle registerTitleStyle(BuildContext context) =>
    Theme.of(context).textTheme.displaySmall?.copyWith(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      height: 40.14 / 36,
      letterSpacing: -0.54,
      color: Theme.of(context).colorScheme.onSurface,
    ) ??
    const TextStyle();

TextStyle registerLabelStyle(BuildContext context) =>
    Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      height: 17.58 / 15,
      color: Theme.of(context).colorScheme.onSurface,
    ) ??
    const TextStyle();

TextStyle registerFieldTextStyle(BuildContext context) =>
    Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 19.0 / 16,
      color: Theme.of(context).colorScheme.onSurface,
    ) ??
    const TextStyle();

InputDecoration registerInputDecoration(
  BuildContext context, {
  required String hint,
  String? errorText,
}) {
  final theme = Theme.of(context);
  return buildFilledInputDecoration(
    context,
    hintText: hint,
    errorText: errorText,
    hintStyle:
        theme.textTheme.bodyMedium?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 18.0 / 15,
          color: theme.colorScheme.onSurfaceVariant,
        ) ??
        const TextStyle(),
  );
}
