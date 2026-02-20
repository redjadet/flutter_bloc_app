import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoggedOutBottomIndicator extends StatelessWidget {
  const LoggedOutBottomIndicator({
    required this.scale,
    required this.verticalScale,
    super.key,
  });

  final double scale;
  final double verticalScale;

  @override
  Widget build(final BuildContext context) => SizedBox(
    width: 135 * scale,
    height: 5 * verticalScale,
    child: _ShapeIndicator(
      width: 135 * scale,
      height: 5 * verticalScale,
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
        color: Theme.of(context).colorScheme.onSurface,
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}
