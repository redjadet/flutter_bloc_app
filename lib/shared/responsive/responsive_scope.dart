import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/constants/constants.dart';
import 'package:flutter_bloc_app/shared/responsive/responsive_config.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_framework/responsive_framework.dart';

/// Wraps the app with both ScreenUtil and ResponsiveFramework configuration so
/// layout decisions flow through a single entry point.
class ResponsiveScope extends StatefulWidget {
  const ResponsiveScope({required this.child, super.key});

  final Widget child;

  @override
  State<ResponsiveScope> createState() => _ResponsiveScopeState();
}

class _ResponsiveScopeState extends State<ResponsiveScope> {
  @override
  void dispose() {
    UI.markScreenUtilUnready();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => ScreenUtilInit(
    designSize: AppConstants.designSize,
    minTextAdapt: true,
    splitScreenMode: true,
    child: ResponsiveBreakpoints.builder(
      breakpoints: ResponsiveConfig.breakpoints,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: AppConstants.minContentWidth,
          minHeight: AppConstants.minContentHeight,
        ),
        child: widget.child,
      ),
    ),
    builder: (final context, final child) {
      UI.markScreenUtilReady();
      return child ?? const SizedBox.shrink();
    },
  );
}
