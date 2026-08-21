// Fixture only — correct overlay re-provide.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class _DemoCubit extends Cubit<int> {
  _DemoCubit() : super(0);
}

class _DemoControls extends StatelessWidget {
  const _DemoControls();

  @override
  Widget build(BuildContext context) {
    context.read<_DemoCubit>();
    return const SizedBox.shrink();
  }
}

Future<void> openSheet(BuildContext context) {
  final _DemoCubit cubit = context.read<_DemoCubit>();
  return showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => BlocProvider<_DemoCubit>.value(
      value: cubit,
      child: const _DemoControls(),
    ),
  );
}
