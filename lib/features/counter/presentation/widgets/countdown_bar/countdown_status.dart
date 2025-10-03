import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CountdownStatus extends StatelessWidget {
  const CountdownStatus({
    super.key,
    required this.active,
    required this.color,
    required this.label,
    required this.animDuration,
  });

  final bool active;
  final Color color;
  final String label;
  final Duration animDuration;

  @override
  Widget build(BuildContext context) {
    final TextStyle? base = Theme.of(context).textTheme.bodyMedium;
    final double baseSize = (base?.fontSize ?? 14).spMax;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedSwitcher(
          duration: animDuration,
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: Icon(
            active ? Icons.timer : Icons.pause_circle_filled,
            key: ValueKey<bool>(active),
            color: color,
            size: UI.iconM,
          ),
        ),
        SizedBox(width: UI.horizontalGapM),
        Flexible(
          child: AnimatedSwitcher(
            duration: animDuration,
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Text(
              label,
              key: ValueKey<String>(active ? 'active' : 'paused'),
              style: base?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: baseSize,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ),
      ],
    );
  }
}
