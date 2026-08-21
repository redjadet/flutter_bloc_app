// Fixture only — intentional ProviderNotFound risk (custom sheet root, no re-provide).
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
  return showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => const _DemoControls(),
  );
}
