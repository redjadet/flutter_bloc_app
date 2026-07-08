import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class LibraryDemoIconButton extends StatelessWidget {
  const LibraryDemoIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    required this.backgroundColor,
    this.size,
    super.key,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final Color backgroundColor;
  final double? size;

  @override
  Widget build(final BuildContext context) {
    final double buttonSize = size ?? EpochSpacing.buttonSize;
    final BorderRadius radius = BorderRadius.circular(
      EpochSpacing.borderRadiusLarge,
    );

    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: buttonSize,
        height: buttonSize,
        child: PlatformAdaptive.button(
          context: context,
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          color: backgroundColor,
          minSize: buttonSize,
          borderRadius: radius,
          materialStyle: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            minimumSize: Size.square(buttonSize),
            padding: EdgeInsets.zero,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: radius),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Center(child: icon),
        ),
      ),
    );
  }
}
