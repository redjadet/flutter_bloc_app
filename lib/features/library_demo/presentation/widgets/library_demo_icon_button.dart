import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_theme.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

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
