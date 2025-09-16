import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';

import 'package:flutter_bloc_app/shared/widgets/countdown_bar/countdown_bar_content.dart';

class CountdownBar extends StatefulWidget {
  const CountdownBar({super.key});

  @override
  State<CountdownBar> createState() => _CountdownBarState();
}

class _CountdownBarState extends State<CountdownBar> {
  int? _cycleTotalSeconds;
  static const Duration _animFast = UI.animFast;

  AppLocalizations _l10n(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations) ??
      AppLocalizationsEn();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterCubit, CounterState>(
      builder: (context, state) {
        final bool active = state.isAutoDecrementActive;
        final bool isLoading = state.status == CounterStatus.loading;
        final AppLocalizations l10n = _l10n(context);
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
  }
}
