import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';

class CounterActions extends StatelessWidget {
  const CounterActions({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return BlocSelector<CounterCubit, CounterState, bool>(
      selector: (final state) => state.status.isLoading,
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
