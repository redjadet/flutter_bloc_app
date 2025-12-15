import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_bloc_app/shared/widgets/view_status_switcher.dart';

class CounterHint extends StatelessWidget {
  const CounterHint({super.key});

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return ViewStatusSwitcher<CounterCubit, CounterState, _CounterHintData>(
      selector: (final state) => _CounterHintData(
        count: state.count,
        isLoading: state.status.isLoading,
      ),
      isLoading: (final data) => data.isLoading,
      isError: (_) => false,
      loadingBuilder: (final _) => const SizedBox.shrink(),
      builder: (final context, final data) {
        if (data.count != 0) {
          return const SizedBox.shrink();
        }
        return Text(
          l10n.startAutoHint,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        );
      },
    );
  }
}

@immutable
class _CounterHintData {
  const _CounterHintData({required this.count, required this.isLoading});

  final int count;
  final bool isLoading;
}
