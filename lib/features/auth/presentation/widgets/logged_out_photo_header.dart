import 'package:flutter/material.dart';

class LoggedOutPhotoHeader extends StatelessWidget {
  const LoggedOutPhotoHeader({
    required this.scale,
    required this.verticalScale,
    super.key,
  });

  final double scale;
  final double verticalScale;

  @override
  Widget build(final BuildContext context) => SizedBox(
    height: 54 * verticalScale,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38 * scale,
          height: 38 * scale,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4 * scale),
            gradient: const LinearGradient(
              begin: Alignment(0.296, -0.064),
              end: Alignment(0.704, 1.064),
              colors: [
                Color(0xFFFF00D7),
                Color(0xFFFF4D00),
              ],
            ),
          ),
          child: Icon(
            Icons.add,
            size: 24 * scale,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        SizedBox(width: 8 * scale),
        Text(
          'photo',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 48 * scale,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: -0.72 * scale,
            height: 53.52 / 48,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
