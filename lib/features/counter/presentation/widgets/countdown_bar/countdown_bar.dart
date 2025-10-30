import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/features/counter/presentation/widgets/countdown_bar/countdown_bar_content.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';

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
  ) => BlocBuilder<CounterCubit, CounterState>(
    builder: (final context, final state) {
      final bool active = state.isAutoDecrementActive;
      final bool isLoading = state.status.isLoading;
      final l10n = context.l10n;
      final ColorScheme colors = Theme.of(context).colorScheme;

      _updateCycleTotalSeconds(state.countdownSeconds);
      final int total =
          _cycleTotalSeconds ?? CounterState.defaultCountdownSeconds;
      final double progress = (state.countdownSeconds / total).clamp(0.0, 1.0);

      final Color targetColor = active
          ? Color.lerp(colors.error, colors.primary, progress) ?? colors.primary
          : colors.primary;

      return CountdownBarContent(
        active: active,
        isLoading: isLoading,
        progress: progress,
        countdownSeconds: state.countdownSeconds,
        targetColor: targetColor,
        colors: colors,
        l10n: l10n,
        animFast: _animFast,
      );
    },
  );

  void _updateCycleTotalSeconds(final int seconds) {
    final int current = _cycleTotalSeconds ?? seconds;
    _cycleTotalSeconds = math.max(current, seconds);
  }
}
