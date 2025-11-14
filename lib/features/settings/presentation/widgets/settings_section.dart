import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.title,
    required this.child,
    super.key,
    this.spacing,
  });

  final String title;
  final Widget child;
  final double? spacing;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double gap = spacing ?? context.responsiveGapS;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        SizedBox(height: gap),
        child,
      ],
    );
  }
}
