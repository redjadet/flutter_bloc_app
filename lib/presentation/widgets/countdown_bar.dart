import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/counter_cubit.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CountdownBar extends StatefulWidget {
  const CountdownBar({super.key});

  @override
  State<CountdownBar> createState() => _CountdownBarState();
}

class _CountdownBarState extends State<CountdownBar> {
  int? _cycleTotalSeconds;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterCubit, CounterState>(
      builder: (context, state) {
        final bool active = state.isAutoDecrementActive;
        final AppLocalizations l10n =
            Localizations.of<AppLocalizations>(context, AppLocalizations) ??
            AppLocalizationsEn();
        final ColorScheme colors = Theme.of(context).colorScheme;

        if (_cycleTotalSeconds == null ||
            state.countdownSeconds > (_cycleTotalSeconds ?? 0)) {
          _cycleTotalSeconds = state.countdownSeconds;
        }
        final int total = _cycleTotalSeconds ?? 5;
        final double progress = (state.countdownSeconds / total).clamp(
          0.0,
          1.0,
        );

        final Color targetColor = active
            ? Color.lerp(colors.error, colors.primary, progress) ??
                  colors.primary
            : colors.primary;

        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: Material(
              elevation: 0,
              color: colors.surface,
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<Color?>(
                      duration: const Duration(milliseconds: 220),
                      tween: ColorTween(end: targetColor),
                      builder: (context, animatedColor, _) {
                        final Color c = animatedColor ?? targetColor;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                              child: Icon(
                                active
                                    ? Icons.timer
                                    : Icons.pause_circle_filled,
                                key: ValueKey<bool>(active),
                                color: c,
                                size: 20.sp,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                              child: Text(
                                active
                                    ? l10n.nextAutoDecrementIn(
                                        state.countdownSeconds,
                                      )
                                    : l10n.autoDecrementPaused,
                                key: ValueKey<String>(
                                  active
                                      ? 'active-${state.countdownSeconds}'
                                      : 'paused',
                                ),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: c,
                                      fontSize:
                                          (Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.fontSize ??
                                                  14)
                                              .sp,
                                    ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 10.h),
                    TweenAnimationBuilder<Color?>(
                      duration: const Duration(milliseconds: 220),
                      tween: ColorTween(end: targetColor),
                      builder: (context, animatedColor, _) {
                        final Color barColor = animatedColor ?? targetColor;
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(999.r),
                          child: LinearProgressIndicator(
                            value: active ? progress : 0,
                            minHeight: 6.h,
                            backgroundColor: colors.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(barColor),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
