import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc_app/counter_cubit.dart';

class CounterDisplay extends StatelessWidget {
  const CounterDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterCubit, CounterState>(
      builder: (context, state) {
        final String lastChangedText = state.lastChanged != null
            ? DateFormat.yMd(
                Localizations.localeOf(context).languageCode,
              ).add_jm().format(state.lastChanged!)
            : '-';
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${state.count}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Last changed: $lastChangedText',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      },
    );
  }
}
