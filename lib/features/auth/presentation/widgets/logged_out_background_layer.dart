import 'package:flutter/material.dart';

class LoggedOutBackgroundLayer extends StatelessWidget {
  const LoggedOutBackgroundLayer({
    required this.scale,
    required this.constraints,
    super.key,
  });

  final double scale;
  final BoxConstraints constraints;

  @override
  Widget build(final BuildContext context) => Positioned(
    left: 0,
    top: 0,
    right: 0,
    height: 707 * scale,
    child: _BackgroundImage(
      width: constraints.maxWidth,
      height: 707 * scale,
    ),
  );
}

class _BackgroundImage extends StatelessWidget {
  const _BackgroundImage({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(final BuildContext context) => Image.asset(
    'assets/figma/Logged_out_0-2/Rectangle_0-42.png',
    width: width,
    height: height,
    fit: BoxFit.fill,
    errorBuilder: (final context, final error, final stackTrace) => Container(
      width: width,
      height: height,
      color: const Color(0xFF0B0C0D),
    ),
  );
}
