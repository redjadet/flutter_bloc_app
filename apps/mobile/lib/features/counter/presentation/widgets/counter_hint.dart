import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/widgets/view_status_switcher.dart';
import 'package:flutter_bloc_app/features/counter/presentation/cubit/counter_cubit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:material_ui/material_ui.dart';

part 'counter_hint.freezed.dart';

class CounterHint extends StatelessWidget {
  const CounterHint({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return ViewStatusSwitcher<CounterCubit, CounterState, _CounterHintData>(
      selector: (state) => _CounterHintData(
        count: state.count,
        isLoading: state.isLoading,
      ),
      isLoading: (data) => data.isLoading,
      isError: (_) => false,
      loadingBuilder: (_) => const SizedBox.shrink(),
      builder: (context, data) {
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

@freezed
abstract class _CounterHintData with _$CounterHintData {
  const factory _CounterHintData({
    required int count,
    required bool isLoading,
  }) = __CounterHintData;
}
