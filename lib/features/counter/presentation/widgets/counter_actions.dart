import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';

class CounterActions extends StatelessWidget {
  const CounterActions({super.key});

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n =
        Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizationsEn();
    return BlocSelector<CounterCubit, CounterState, bool>(
      selector: (final state) => state.status == CounterStatus.loading,
      builder: (final context, final isLoading) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            button: true,
            label: l10n.incrementTooltip,
            child: FloatingActionButton(
              heroTag: 'fab_increment',
              onPressed: isLoading
                  ? null
                  : () => context.read<CounterCubit>().increment(),
              tooltip: l10n.incrementTooltip,
              child: Center(child: Icon(Icons.add, size: UI.iconL)),
            ),
          ),
          SizedBox(height: UI.gapM),
          Semantics(
            button: true,
            label: l10n.decrementTooltip,
            child: FloatingActionButton(
              heroTag: 'fab_decrement',
              onPressed: isLoading
                  ? null
                  : () => context.read<CounterCubit>().decrement(),
              tooltip: l10n.decrementTooltip,
              child: Center(child: Icon(Icons.remove, size: UI.iconL)),
            ),
          ),
        ],
      ),
    );
  }
}
