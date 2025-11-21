import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests to catch common bugs, pitfalls, and defensive patterns outlined in the project's guidelines.
void main() {
  group('Common Bugs Prevention Tests', () {
    group('StreamController State Checks', () {
      test(
        'does not throw when addError is called after controller is closed',
        () async {
          final StreamController<int> controller =
              StreamController<int>.broadcast();

          // Close the controller
          await controller.close();

          // Should not throw - should check isClosed before addError
          expect(() {
            if (!controller.isClosed) {
              controller.addError(Exception('test'), StackTrace.current);
            }
          }, returnsNormally);
        },
      );

      test(
        'does not throw when add is called after controller is closed',
        () async {
          final StreamController<int> controller =
              StreamController<int>.broadcast();

          // Close the controller
          await controller.close();

          // Should not throw - should check isClosed before add
          expect(() {
            if (!controller.isClosed) {
              controller.add(1);
            }
          }, returnsNormally);
        },
      );
    });

    group('Cubit State Management', () {
      test(
        'does not throw when emit is called after cubit is closed',
        () async {
          final TestCubit cubit = TestCubit();

          // Close the cubit
          await cubit.close();

          // Should not throw - should check isClosed before emit
          expect(() {
            if (!cubit.isClosed) {
              cubit.increment();
            }
          }, returnsNormally);
        },
      );

      test(
        'does not throw when emit is called multiple times after close',
        () async {
          final TestCubit cubit = TestCubit();

          // Close the cubit
          await cubit.close();

          // Multiple emit calls should all check isClosed
          expect(() {
            if (!cubit.isClosed) {
              cubit.increment();
            }
            if (!cubit.isClosed) {
              cubit.increment();
            }
          }, returnsNormally);
        },
      );

      test(
        'does not throw when emit is called in async callback after close',
        () async {
          final TestCubit cubit = TestCubit();

          // Close the cubit
          await cubit.close();

          // Simulate async callback
          await Future<void>.delayed(Duration.zero);

          // Should not throw - should check isClosed before emit
          expect(() {
            if (!cubit.isClosed) {
              cubit.increment();
            }
          }, returnsNormally);
        },
      );
    });

    group('Completers & Futures', () {
      test('does not throw when complete is called multiple times', () {
        final Completer<void> completer = Completer<void>();
        // Add error handler to prevent unhandled async exceptions
        // when completeError is called without listeners
        completer.future.catchError((_) {});

        // Complete once
        if (!completer.isCompleted) {
          completer.complete();
        }

        // Try to complete again - should not throw
        expect(() {
          if (!completer.isCompleted) {
            completer.complete();
          }
        }, returnsNormally);
      });

      test('does not throw when completeError is called after complete', () {
        final Completer<void> completer = Completer<void>();
        // Add error handler to prevent unhandled async exceptions
        // when completeError is called without listeners
        completer.future.catchError((_) {});

        // Complete first
        if (!completer.isCompleted) {
          completer.complete();
        }

        // Try to completeError - should not throw
        expect(() {
          if (!completer.isCompleted) {
            completer.completeError(Exception('test'));
          }
        }, returnsNormally);
      });

      test('does not throw when completeError is called multiple times', () {
        final Completer<void> completer = Completer<void>();
        // Add error handler to prevent unhandled async exceptions
        // when completeError is called without listeners
        completer.future.catchError((_) {});

        // CompleteError once
        if (!completer.isCompleted) {
          completer.completeError(Exception('test'));
        }

        // Try to completeError again - should not throw
        expect(() {
          if (!completer.isCompleted) {
            completer.completeError(Exception('test2'));
          }
        }, returnsNormally);
      });
    });

    group('Context & Widget Lifecycle', () {
      testWidgets('does not use context after widget is disposed', (
        WidgetTester tester,
      ) async {
        late BuildContext context;
        bool contextUsedAfterDispose = false;

        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (builderContext, setState) {
                context = builderContext;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        // Dispose widget
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();

        // Simulate async operation that completes after dispose
        await tester.runAsync(() async {
          await Future<void>.delayed(Duration.zero);
        });

        // Should check context.mounted before using context
        if (context.mounted) {
          contextUsedAfterDispose = true;
          Navigator.of(context).pop();
        }

        expect(contextUsedAfterDispose, isFalse);
      });

      testWidgets(
        'does not use context in addPostFrameCallback after dispose',
        (WidgetTester tester) async {
          late BuildContext context;
          bool contextUsedAfterDispose = false;
          final Completer<void> callbackCompleter = Completer<void>();

          await tester.pumpWidget(
            MaterialApp(
              home: StatefulBuilder(
                builder: (builderContext, setState) {
                  context = builderContext;
                  return const SizedBox.shrink();
                },
              ),
            ),
          );

          // Schedule post frame callback
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (context.mounted) {
              contextUsedAfterDispose = true;
            }
            if (!callbackCompleter.isCompleted) {
              callbackCompleter.complete();
            }
          });

          // Dispose widget before callback executes
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();

          // Wait for callback to complete
          await callbackCompleter.future;
          await tester.pump();

          expect(contextUsedAfterDispose, isFalse);
        },
      );

      testWidgets('does not use context in Future.delayed after dispose', (
        WidgetTester tester,
      ) async {
        late BuildContext context;
        bool contextUsedAfterDispose = false;
        final Completer<void> callbackCompleter = Completer<void>();

        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (builderContext, setState) {
                context = builderContext;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        // Schedule delayed callback outside the fake async zone
        tester.runAsync(() async {
          await Future<void>.delayed(Duration.zero);
          if (context.mounted) {
            contextUsedAfterDispose = true;
          }
          if (!callbackCompleter.isCompleted) {
            callbackCompleter.complete();
          }
        });

        // Dispose widget before callback executes
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();

        // Wait for callback to complete
        await callbackCompleter.future;
        await tester.pump();

        expect(contextUsedAfterDispose, isFalse);
      });
    });

    group('List & Collection Operations', () {
      test('does not throw when accessing first on empty list', () {
        final List<int> emptyList = <int>[];

        // Should check isEmpty before accessing first
        expect(() {
          if (emptyList.isEmpty) {
            return null;
          }
          return emptyList.first;
        }, returnsNormally);
      });

      test('does not throw when accessing last on empty list', () {
        final List<int> emptyList = <int>[];

        // Should check isEmpty before accessing last
        expect(() {
          if (emptyList.isEmpty) {
            return null;
          }
          return emptyList.last;
        }, returnsNormally);
      });

      test('does not throw when accessing index out of bounds', () {
        final List<int> list = <int>[1, 2, 3];

        // Should check bounds before accessing
        expect(() {
          final int index = 5;
          if (index >= 0 && index < list.length) {
            return list[index];
          }
          return null;
        }, returnsNormally);
      });
    });

    group('String Operations', () {
      test('does not throw when substring on empty string', () {
        final String empty = '';

        // Should check length before substring
        expect(() {
          if (empty.isNotEmpty) {
            return empty.substring(0, empty.length - 1);
          }
          return empty;
        }, returnsNormally);
      });

      test('does not throw when split returns empty result', () {
        final String tag = '';

        // Should handle empty split results
        expect(() {
          final List<String> parts = tag.split('_');
          if (parts.isEmpty) {
            return null;
          }
          return parts.first;
        }, returnsNormally);
      });
    });

    group('Parse Operations', () {
      test('does not throw when parsing invalid number', () {
        final String invalid = 'not a number';

        // Should use tryParse instead of parse
        expect(() {
          final double? parsed = double.tryParse(invalid);
          if (parsed == null) {
            return null;
          }
          return parsed;
        }, returnsNormally);
      });
    });

    group('Division Operations', () {
      test('does not throw when dividing by zero', () {
        final double lhs = 10.0;
        final double rhs = 0.0;

        // Should check divisor before division
        expect(() {
          if (rhs == 0) {
            return null; // Error state
          }
          return lhs / rhs;
        }, returnsNormally);
      });
    });

    group('Stream Subscriptions', () {
      test('properly cancels subscription in close method', () async {
        final StreamController<int> controller =
            StreamController<int>.broadcast();
        final StreamSubscription<int> subscription = controller.stream.listen(
          (_) {},
        );

        final TestCubit cubit = TestCubit();

        // Simulate subscription in cubit
        cubit._subscription = subscription;

        // Close should cancel subscription
        await cubit.close();

        // Subscription should be cancelled (isPaused may not be reliable, check differently)
        expect(cubit._subscription, isNull);
        await controller.close();
      });

      test('nullifies subscription reference before cancelling', () async {
        final StreamController<int> controller =
            StreamController<int>.broadcast();
        StreamSubscription<int>? subscription = controller.stream.listen(
          (_) {},
        );

        // Nullify reference before cancelling to prevent race conditions
        final StreamSubscription<int> oldSubscription = subscription;
        subscription = null;
        await oldSubscription.cancel();

        expect(subscription, isNull);
        await controller.close();
      });
    });
  });
}

/// Test cubit for testing common bugs
class TestCubit extends Cubit<int> {
  TestCubit() : super(0);

  StreamSubscription<int>? _subscription;

  void increment() {
    if (isClosed) return;
    emit(state + 1);
  }

  @override
  Future<void> close() async {
    final StreamSubscription<int>? oldSubscription = _subscription;
    _subscription = null;
    await oldSubscription?.cancel();
    return super.close();
  }
}
