import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_bloc_app/counter_cubit.dart';
import 'package:flutter_bloc_app/domain/domain.dart';
import 'package:flutter_bloc_app/presentation/pages/home_page.dart';

class ThrowingRepo implements CounterRepository {
  @override
  Future<CounterSnapshot> load() async {
    throw Exception('load failed');
  }

  @override
  Future<void> save(CounterSnapshot snapshot) async {
    throw Exception('save failed');
  }
}

void main() {
  testWidgets('shows SnackBar on load error and clears error', (tester) async {
    final CounterCubit cubit = CounterCubit(repository: ThrowingRepo());

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: const MaterialApp(home: MyHomePage(title: 'Test Home')),
      ),
    );

    // Trigger load error
    await cubit.loadInitial();

    // Let the BlocListener react and display SnackBar
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Failed to load saved counter'), findsOneWidget);

    // The listener should clear the error after showing
    expect(cubit.state.errorMessage, isNull);

    await cubit.close();
  });
}
