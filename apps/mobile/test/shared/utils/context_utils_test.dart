import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/utils/context_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContextUtils', () {
    testWidgets('ensureMounted returns true when context is mounted', (
      final tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TestWidget())),
      );

      final BuildContext context = tester.element(find.byType(TestWidget));
      final bool result = ContextUtils.ensureMounted(context);

      expect(result, isTrue);
    });

    testWidgets('ensureMounted returns false when context is not mounted', (
      final tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TestWidget())),
      );

      final BuildContext context = tester.element(find.byType(TestWidget));

      // Remove widget from tree
      await tester.pumpWidget(const SizedBox());

      final bool result = ContextUtils.ensureMounted(
        context,
        debugLabel: 'test',
      );

      expect(result, isFalse);
    });

    testWidgets(
      'ensureMounted logs when debugLabel is provided and not mounted',
      (final tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: TestWidget())),
        );

        final BuildContext context = tester.element(find.byType(TestWidget));

        // Remove widget from tree
        await tester.pumpWidget(const SizedBox());

        ContextUtils.ensureMounted(context, debugLabel: 'test-operation');

        // Should not throw
        expect(tester.takeException(), isNull);
      },
    );

    test('logNotMounted logs debug message', () {
      ContextUtils.logNotMounted('test-operation');

      // Should not throw
      expect(() => ContextUtils.logNotMounted('test'), returnsNormally);
    });
  });
}

class TestWidget extends StatelessWidget {
  const TestWidget({super.key});

  @override
  Widget build(final BuildContext context) => const SizedBox();
}
