import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/utils/bloc_provider_helpers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('BlocProviderHelpers', () {
    testWidgets('withAsyncInit creates provider and calls init', (
      tester,
    ) async {
      bool initCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProviderHelpers.withAsyncInit<TestCubit>(
            create: () => TestCubit(),
            init: (cubit) async {
              initCalled = true;
            },
            child: const TestConsumerWidget(),
          ),
        ),
      );

      await tester.pump();

      expect(initCalled, isTrue);
      expect(find.byType(TestWidget), findsOneWidget);
    });

    testWidgets(
      'providerWithAsyncInit creates provider for MultiBlocProvider',
      (tester) async {
        bool initCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: MultiBlocProvider(
              providers: [
                BlocProviderHelpers.providerWithAsyncInit<TestCubit>(
                  create: () => TestCubit(),
                  init: (cubit) async {
                    initCalled = true;
                  },
                ),
              ],
              child: const TestConsumerWidget(),
            ),
          ),
        );

        await tester.pump();

        expect(initCalled, isTrue);
        expect(find.byType(TestWidget), findsOneWidget);
      },
    );

    testWidgets('withCubit creates type-safe provider', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProviderHelpers.withCubit<TestCubit, TestState>(
            create: () => TestCubit(),
            builder: (context, cubit) {
              return Text('${cubit.state.value}');
            },
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets(
      'withCubitAsyncInit creates provider with async init and builder',
      (tester) async {
        bool initCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProviderHelpers.withCubitAsyncInit<TestCubit, TestState>(
              create: () => TestCubit(),
              init: (cubit) async {
                initCalled = true;
              },
              builder: (context, cubit) {
                return Text('${cubit.state.value}');
              },
            ),
          ),
        );

        await tester.pump();

        expect(initCalled, isTrue);
        expect(find.text('0'), findsOneWidget);
      },
    );
  });
}

class TestCubit extends Cubit<TestState> {
  TestCubit() : super(const TestState(value: 0));
}

class TestState {
  const TestState({required this.value});

  final int value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestState &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class TestWidget extends StatelessWidget {
  const TestWidget({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox();
}

class TestConsumerWidget extends StatelessWidget {
  const TestConsumerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    context.cubit<TestCubit>();
    return const TestWidget();
  }
}
