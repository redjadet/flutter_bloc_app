import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../ui/ui_constants.dart';
import 'responsive_config.dart';

/// Wraps the app with ScreenUtil + ResponsiveFramework configuration.
///
/// Defaults match the existing app shell expectations; callers can override if
/// a different design size or minimum constraints are required.
class ResponsiveScope extends StatefulWidget {
  const ResponsiveScope({
    required this.child,
    super.key,
    this.designSize = const Size(390, 844),
    this.breakpoints = ResponsiveConfig.breakpoints,
    this.constraints = const BoxConstraints(minWidth: 390, minHeight: 390),
  });

  final Widget child;
  final Size designSize;
  final List<Breakpoint> breakpoints;
  final BoxConstraints constraints;

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
    designSize: widget.designSize,
    minTextAdapt: true,
    splitScreenMode: true,
    child: ResponsiveBreakpoints.builder(
      breakpoints: widget.breakpoints,
      child: ConstrainedBox(
        constraints: widget.constraints,
        child: widget.child,
      ),
    ),
    builder: (final context, final child) {
      UI.markScreenUtilReady();
      return child ?? const SizedBox.shrink();
    },
  );
}
