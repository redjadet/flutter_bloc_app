import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/features/counter/presentation/widgets/counter_display/counter_display_card.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';

class CounterDisplay extends StatefulWidget {
  const CounterDisplay({super.key});

  @override
  State<CounterDisplay> createState() => _CounterDisplayState();
}

class _CounterDisplayState extends State<CounterDisplay> {
  int? _cycleTotalSeconds;

  static const Duration _animFast = UI.animFast;
  static const Duration _animMedium = UI.animMedium;

  AppLocalizations _l10n(final BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations) ??
      AppLocalizationsEn();

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colors = theme.colorScheme;
    final AppLocalizations l10n = _l10n(context);

    return BlocSelector<CounterCubit, CounterState, _DisplayState>(
      selector: (final state) => _DisplayState(
        count: state.count,
        countdownSeconds: state.countdownSeconds,
        isActive: state.isAutoDecrementActive,
        lastChanged: state.lastChanged,
      ),
      builder: (final context, final data) {
        if (!data.isActive) {
          _cycleTotalSeconds = data.countdownSeconds;
        } else {
          _cycleTotalSeconds ??= data.countdownSeconds;
          if ((_cycleTotalSeconds ?? 0) < data.countdownSeconds) {
            _cycleTotalSeconds = data.countdownSeconds;
          }
        }
        final int total = _cycleTotalSeconds ?? 5;
        final double progress = (data.countdownSeconds / total).clamp(0.0, 1.0);

        final Color cardColor = data.isActive
            ? Color.lerp(
                    colors.errorContainer.withValues(alpha: 0.08),
                    colors.surfaceContainerHighest,
                    progress,
                  ) ??
                  colors.surfaceContainerHighest
            : colors.surfaceContainerHighest;

        return CounterDisplayCard(
          count: data.count,
          isActive: data.isActive,
          lastChanged: data.lastChanged,
          cardColor: cardColor,
          colors: colors,
          textTheme: textTheme,
          l10n: l10n,
          animFast: _animFast,
          animMedium: _animMedium,
        );
      },
    );
  }
}

@immutable
class _DisplayState {
  const _DisplayState({
    required this.count,
    required this.countdownSeconds,
    required this.isActive,
    required this.lastChanged,
  });

  final int count;
  final int countdownSeconds;
  final bool isActive;
  final DateTime? lastChanged;
}
