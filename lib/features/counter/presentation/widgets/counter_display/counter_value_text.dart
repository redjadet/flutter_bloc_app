import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CounterValueText extends StatelessWidget {
  const CounterValueText({
    super.key,
    required this.count,
    required this.textTheme,
    required this.animDuration,
  });

  final int count;
  final TextTheme textTheme;
  final Duration animDuration;

  @override
  Widget build(final BuildContext context) => AnimatedSwitcher(
    duration: animDuration,
    switchInCurve: Curves.easeOut,
    switchOutCurve: Curves.easeIn,
    transitionBuilder: (final child, final animation) => ScaleTransition(
      scale: Tween<double>(begin: 0.9, end: 1).animate(animation),
      child: child,
    ),
    child: Text(
      '$count',
      key: ValueKey<int>(count),
      semanticsLabel: 'count $count',
      style: textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: (textTheme.displaySmall?.fontSize ?? 36).spMax,
      ),
    ),
  );
}
