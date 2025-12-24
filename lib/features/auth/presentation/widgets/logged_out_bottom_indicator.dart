import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoggedOutBottomIndicator extends StatelessWidget {
  const LoggedOutBottomIndicator({
    required this.scale,
    required this.horizontalOffset,
    super.key,
  });

  final double scale;
  final double horizontalOffset;

  @override
  Widget build(final BuildContext context) => Positioned(
    left: horizontalOffset + 120 * scale,
    top: 799 * scale,
    width: 135 * scale,
    height: 5 * scale,
    child: _ShapeIndicator(
      width: 135 * scale,
      height: 5 * scale,
    ),
  );
}

class _ShapeIndicator extends StatelessWidget {
  const _ShapeIndicator({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(final BuildContext context) => SvgPicture.asset(
    'assets/figma/Logged_out_0-2/Shape_0-115.svg',
    width: width,
    height: height,
    fit: BoxFit.fill,
    placeholderBuilder: (final context) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}
