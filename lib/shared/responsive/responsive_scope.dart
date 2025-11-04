import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/constants.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_framework/responsive_framework.dart';

/// Wraps the app with both ScreenUtil and ResponsiveFramework configuration so
/// layout decisions flow through a single entry point.
class ResponsiveScope extends StatelessWidget {
  const ResponsiveScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(final BuildContext context) => ScreenUtilInit(
    designSize: AppConstants.designSize,
    minTextAdapt: true,
    splitScreenMode: true,
    child: ResponsiveBreakpoints.builder(
      breakpoints: const [
        Breakpoint(
          start: 0,
          end: AppConstants.mobileBreakpoint - 1,
          name: MOBILE,
        ),
        Breakpoint(
          start: AppConstants.mobileBreakpoint,
          end: AppConstants.tabletBreakpoint - 1,
          name: TABLET,
        ),
        Breakpoint(
          start: AppConstants.tabletBreakpoint,
          end: double.infinity,
          name: DESKTOP,
        ),
      ],
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: AppConstants.minContentWidth,
          minHeight: AppConstants.minContentHeight,
        ),
        child: child,
      ),
    ),
    builder: (final context, final child) {
      UI.screenUtilReady = true;
      return child ?? const SizedBox.shrink();
    },
  );
}
