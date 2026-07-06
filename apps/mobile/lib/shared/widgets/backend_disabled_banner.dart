import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';

class BackendDisabledBanner extends StatelessWidget {
  const BackendDisabledBanner({
    required this.visible,
    super.key,
  });

  final bool visible;

  @override
  Widget build(final BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveHorizontalGapL,
        vertical: context.responsiveGapS,
      ),
      child: CommonCard(
        color: colors.surfaceContainerHighest,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.cloud_off,
              color: colors.onSurface,
            ),
            SizedBox(width: context.responsiveGapS),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.backendDisabledTitle,
                    style: theme.textTheme.titleSmall,
                  ),
                  SizedBox(height: context.responsiveGapXS),
                  Text(
                    l10n.backendDisabledMessage,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// EOF
