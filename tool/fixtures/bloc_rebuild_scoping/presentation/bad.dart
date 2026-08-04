import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class _BadRebuildCubit extends Cubit<int> {
  _BadRebuildCubit() : super(0);
}

class BadBlocRebuildScopingPage extends StatelessWidget {
  const BadBlocRebuildScopingPage({super.key});

  @override
  Widget build(final BuildContext context) {
    return BlocBuilder<_BadRebuildCubit, int>(
      builder: (final context, final count) => Text('$count'),
    );
  }
}
