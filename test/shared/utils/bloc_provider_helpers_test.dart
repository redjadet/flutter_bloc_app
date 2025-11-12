import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/shared/utils/bloc_provider_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

class TestCubit extends Cubit<int> {
  TestCubit() : super(0);

  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 10));
    emit(1);
  }
}

void main() {
  group('BlocProviderHelpers', () {
    testWidgets('withAsyncInit creates BlocProvider and calls init', (
      tester,
    ) async {
      TestCubit? createdCubit;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProviderHelpers.withAsyncInit<TestCubit>(
            create: () {
              createdCubit = TestCubit();
              return createdCubit!;
            },
            init: (cubit) async {
              await cubit.initialize();
            },
            child: Builder(
              builder: (context) {
                // Access the cubit to trigger the create callback
                final cubit = context.read<TestCubit>();
                return Text('State: ${cubit.state}');
              },
            ),
          ),
        ),
      );

      // Allow the widget tree to build (this triggers the create callback)
      await tester.pump();

      // Verify cubit was created
      expect(createdCubit, isNotNull);
      expect(createdCubit!.state, equals(0)); // Initial state

      // Wait for async initialization to complete
      // The init is unawaited, so we need to pump until it completes
      await tester.pumpAndSettle();

      // Verify cubit state was updated by init (from 0 to 1)
      expect(createdCubit, isNotNull);
      expect(createdCubit!.state, equals(1));
    });

    testWidgets('withAsyncInit provides cubit to child widget tree', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProviderHelpers.withAsyncInit<TestCubit>(
            create: TestCubit.new,
            init: (cubit) async {},
            child: Builder(
              builder: (context) {
                final cubit = context.read<TestCubit>();
                return Text('State: ${cubit.state}');
              },
            ),
          ),
        ),
      );

      await tester.pump(); // Allow widget tree to build
      expect(find.text('State: 0'), findsOneWidget);
    });

    testWidgets('withAsyncInit does not block widget tree building', (
      tester,
    ) async {
      bool widgetBuilt = false;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProviderHelpers.withAsyncInit<TestCubit>(
            create: TestCubit.new,
            init: (cubit) async {
              // Long delay to ensure widget builds first
              await Future.delayed(const Duration(seconds: 1));
            },
            child: Builder(
              builder: (context) {
                widgetBuilt = true;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      // Widget should build immediately, not wait for init
      expect(widgetBuilt, isTrue);
    });
  });
}
