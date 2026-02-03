import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

/// Large tap-to-hear button (min 48x48 for accessibility).
class ListenButton extends StatelessWidget {
  const ListenButton({
    required this.onPressed,
    this.compact = false,
    super.key,
  });

  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Semantics(
      button: true,
      label: l10n.playlearnTapToListen,
      child: PlatformAdaptive.filledButton(
        context: context,
        onPressed: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveGapM,
            vertical: context.responsiveGapS,
          ),
          child: compact
              ? Icon(
                  Icons.volume_up,
                  color: theme.colorScheme.onPrimary,
                  size: 28,
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.volume_up,
                      color: theme.colorScheme.onPrimary,
                      size: 28,
                    ),
                    SizedBox(width: context.responsiveGapS),
                    Text(l10n.playlearnListen),
                  ],
                ),
        ),
      ),
    );
  }
}
