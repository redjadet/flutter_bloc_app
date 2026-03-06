import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';

class LoggedOutPhotoHeader extends StatelessWidget {
  const LoggedOutPhotoHeader({
    required this.scale,
    required this.verticalScale,
    super.key,
  });

  final double scale;
  final double verticalScale;

  @override
  Widget build(final BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 54 * verticalScale,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38 * scale,
            height: 38 * scale,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4 * scale),
              gradient: LinearGradient(
                begin: const Alignment(0.296, -0.064),
                end: const Alignment(0.704, 1.064),
                colors: [
                  colorScheme.primary,
                  colorScheme.tertiary,
                ],
              ),
            ),
            child: Icon(
              Icons.add,
              size: 24 * scale,
              color: colorScheme.onPrimary,
            ),
          ),
          SizedBox(width: 8 * scale),
          Flexible(
            child: Text(
              context.l10n.loggedOutPhotoLabel,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 48 * scale,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface,
                letterSpacing: -0.72 * scale,
                height: 53.52 / 48,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
