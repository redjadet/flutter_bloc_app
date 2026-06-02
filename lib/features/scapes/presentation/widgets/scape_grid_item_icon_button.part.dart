part of 'scape_grid_item.dart';

class _ScapeIconButton extends StatelessWidget {
  const _ScapeIconButton({
    required this.size,
    required this.tooltip,
    required this.onPressed,
    required this.icon,
  });

  final double size;
  final String tooltip;
  final VoidCallback onPressed;
  final Widget icon;

  static const double _minTapTargetLogicalPx = 48;

  @override
  Widget build(final BuildContext context) => Semantics(
    button: true,
    label: tooltip,
    child: Tooltip(
      message: tooltip,
      child: Material(
        type: MaterialType.transparency,
        child: InkResponse(
          onTap: onPressed,
          radius: math.max(size * 0.5, _minTapTargetLogicalPx / 2),
          child: SizedBox(
            width: math.max(size, _minTapTargetLogicalPx),
            height: math.max(size, _minTapTargetLogicalPx),
            child: Center(child: icon),
          ),
        ),
      ),
    ),
  );
}
