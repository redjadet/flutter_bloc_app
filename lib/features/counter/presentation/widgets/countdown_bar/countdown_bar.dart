import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/features/counter/presentation/widgets/countdown_bar/countdown_bar_content.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_bloc_app/shared/widgets/type_safe_bloc_selector.dart';

class CountdownBar extends StatefulWidget {
  const CountdownBar({super.key});

  @override
  State<CountdownBar> createState() => _CountdownBarState();
}

class _CountdownBarState extends State<CountdownBar> {
  int? _cycleTotalSeconds;
  static const Duration _animFast = UI.animFast;

  @override
  Widget build(
    final BuildContext context,
  ) {
    final l10n = context.l10n;
    final ColorScheme colors = Theme.of(context).colorScheme;

    return TypeSafeBlocSelector<CounterCubit, CounterState, _CountdownBarData>(
      selector: (final state) => _CountdownBarData(
        active: state.isAutoDecrementActive,
        isLoading: state.status.isLoading,
        countdownSeconds: state.countdownSeconds,
      ),
      builder: (final context, final data) {
        _updateCycleTotalSeconds(data.countdownSeconds);
        final int total =
            _cycleTotalSeconds ?? CounterState.defaultCountdownSeconds;
        final double progress = (data.countdownSeconds / total).clamp(0.0, 1.0);

        final Color targetColor = data.active
            ? Color.lerp(colors.error, colors.primary, progress) ??
                  colors.primary
            : colors.primary;

        return CountdownBarContent(
          active: data.active,
          isLoading: data.isLoading,
          progress: progress,
          countdownSeconds: data.countdownSeconds,
          targetColor: targetColor,
          colors: colors,
          l10n: l10n,
          animFast: _animFast,
        );
      },
    );
  }

  void _updateCycleTotalSeconds(final int seconds) {
    final int current = _cycleTotalSeconds ?? seconds;
    _cycleTotalSeconds = math.max(current, seconds);
  }
}

@immutable
class _CountdownBarData {
  const _CountdownBarData({
    required this.active,
    required this.isLoading,
    required this.countdownSeconds,
  });

  final bool active;
  final bool isLoading;
  final int countdownSeconds;
}
