import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/counter_cubit.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

class CounterActions extends StatelessWidget {
  const CounterActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: () => context.read<CounterCubit>().increment(),
          tooltip: AppLocalizations.of(context).incrementTooltip,
          child: const Icon(Icons.add),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          onPressed: () => context.read<CounterCubit>().decrement(),
          tooltip: AppLocalizations.of(context).decrementTooltip,
          child: const Icon(Icons.remove),
        ),
      ],
    );
  }
}
