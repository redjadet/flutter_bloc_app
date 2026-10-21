import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart';

class CounterValueText extends StatelessWidget {
  const new({
    required this.count,
    required this.textTheme,
    required this.animDuration,
    super.key,
  });

  final int count;
  final TextTheme textTheme;
  final Duration animDuration;

  @override
  Widget build(BuildContext context) {
    final animatedValue = AnimatedSwitcher(
      duration: animDuration,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1).animate(animation),
        child: child,
      ),
      child: Text(
        '$count',
        key: ValueKey<int>(count),
        maxLines: 1,
        softWrap: false,
        style: textTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: (textTheme.displaySmall?.fontSize ?? 36).spMax,
        ),
      ),
    );

    return Semantics(
      label: '$count',
      // AnimatedSwitcher keeps outgoing values mounted during the transition.
      excludeSemantics: true,
      child: FittedBox(fit: BoxFit.scaleDown, child: animatedValue),
    );
  }
}
