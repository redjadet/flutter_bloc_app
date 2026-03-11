import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';

class CounterActions extends StatelessWidget {
  const CounterActions({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: l10n.incrementTooltip,
          child: FloatingActionButton(
            heroTag: 'fab_increment',
            onPressed: () => context.cubit<CounterCubit>().increment(),
            tooltip: l10n.incrementTooltip,
            child: Center(
              child: Icon(Icons.add, size: context.responsiveIconSize),
            ),
          ),
        ),
        SizedBox(height: context.responsiveGapM),
        Semantics(
          button: true,
          label: l10n.decrementTooltip,
          child: FloatingActionButton(
            heroTag: 'fab_decrement',
            onPressed: () => context.cubit<CounterCubit>().decrement(),
            tooltip: l10n.decrementTooltip,
            child: Center(
              child: Icon(Icons.remove, size: context.responsiveIconSize),
            ),
          ),
        ),
      ],
    );
  }
}
