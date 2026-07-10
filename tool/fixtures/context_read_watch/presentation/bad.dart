import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class _BadCounterCubit extends Cubit<int> {
  _BadCounterCubit() : super(0);
}

class BadContextReadWatchPage extends StatelessWidget {
  const BadContextReadWatchPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final count = context.watch<_BadCounterCubit>().state;
    return Text('$count');
  }
}
