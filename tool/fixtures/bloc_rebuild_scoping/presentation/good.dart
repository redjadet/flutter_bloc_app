import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class _GoodRebuildCubit extends Cubit<int> {
  _GoodRebuildCubit() : super(0);
}

class GoodBlocRebuildScopingPage extends StatelessWidget {
  const GoodBlocRebuildScopingPage({super.key});

  @override
  Widget build(final BuildContext context) {
    return BlocBuilder<_GoodRebuildCubit, int>(
      buildWhen: (final prev, final next) => prev != next,
      builder: (final context, final count) => Text('$count'),
    );
  }
}
