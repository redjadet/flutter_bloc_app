import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class _SuppressedCounterCubit extends Cubit<int> {
  _SuppressedCounterCubit() : super(0);
}

class SuppressedContextReadWatchPage extends StatelessWidget {
  const SuppressedContextReadWatchPage({super.key});

  @override
  Widget build(final BuildContext context) {
    // check-ignore: fixture documents intentional suppression for QG-D04
    final count = context.watch<_SuppressedCounterCubit>().state;
    return Text('$count');
  }
}
