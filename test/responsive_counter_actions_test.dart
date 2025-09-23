import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/shared/widgets/counter_actions.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

class _Harness extends StatelessWidget {
  const _Harness({required this.child, this.width, this.height});

  final Widget child;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQueryData(size: Size(width ?? 390, height ?? 844)),
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }
}

void main() {
  group('CounterActions responsive layout', () {
    setUp(() {
      setupSharedPreferencesMock();
    });

    Future<void> pumpHarness(
      WidgetTester tester, {
      required double width,
      required double height,
      required CounterCubit cubit,
    }) async {
      await tester.pumpWidget(
        _Harness(
          width: width,
          height: height,
          child: BlocProvider.value(value: cubit, child: const CounterActions()),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders without overflow on small screen', (tester) async {
      final cubit = CounterCubit(repository: MockCounterRepository(), startTicker: false);
      addTearDown(cubit.close);

      await pumpHarness(tester, width: 240, height: 320, cubit: cubit);

      expect(find.byType(FloatingActionButton), findsNWidgets(2));
    });

    testWidgets('renders without overflow on large screen', (tester) async {
      final cubit = CounterCubit(repository: MockCounterRepository(), startTicker: false);
      addTearDown(cubit.close);

      await pumpHarness(tester, width: 1400, height: 1024, cubit: cubit);

      expect(find.byType(FloatingActionButton), findsNWidgets(2));
    });
  });
}
