import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class _SuppressedRebuildCubit extends Cubit<int> {
  _SuppressedRebuildCubit() : super(0);
}

class SuppressedBlocRebuildScopingPage extends StatelessWidget {
  const SuppressedBlocRebuildScopingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // check-ignore: fixture documents intentional full-state rebuild for QG-D03
    return BlocBuilder<_SuppressedRebuildCubit, int>(
      builder: (context, count) => Text('$count'),
    );
  }
}
