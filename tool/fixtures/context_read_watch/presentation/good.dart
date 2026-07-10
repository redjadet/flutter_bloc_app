import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class _GoodCounterCubit extends Cubit<int> {
  _GoodCounterCubit() : super(0);
}

class GoodContextReadWatchPage extends StatelessWidget {
  const GoodContextReadWatchPage({super.key});

  @override
  Widget build(final BuildContext context) {
    return BlocBuilder<_GoodCounterCubit, int>(
      builder: (final context, final count) => Text('$count'),
    );
  }
}
