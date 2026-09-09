import 'package:design_system/responsive.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('CommonPageLayout', () {
    testWidgets('renders title and body', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CommonPageLayout(
            title: 'Test Title',
            body: Text('Body Content'),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Body Content'), findsOneWidget);
    });

    testWidgets('renders body without responsive wrapper when disabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CommonPageLayout(
            title: 'No Wrapper',
            useResponsiveBody: false,
            body: Text('Plain Body'),
          ),
        ),
      );

      expect(find.text('No Wrapper'), findsOneWidget);
      expect(find.text('Plain Body'), findsOneWidget);
    });

    testWidgets('uses custom appBar instead of CommonAppBar title', (
      tester,
    ) async {
      const customTitle = Key('custom-app-bar-title');

      await tester.pumpWidget(
        MaterialApp(
          home: CommonPageLayout(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: AppBar(title: const Text('Custom', key: customTitle)),
            ),
            useResponsiveBody: false,
            body: const Text('Custom Body'),
          ),
        ),
      );

      expect(find.byKey(customTitle), findsOneWidget);
      expect(find.text('Custom Body'), findsOneWidget);
      expect(find.text('Test Title'), findsNothing);
    });

    testWidgets(
      'responsive body caps maxWidth to nested parent narrower than contentMaxWidth',
      (tester) async {
        // Wide viewport → contentMaxWidth is tablet/desktop (>=720), not the
        // nested 320 parent. Regression for LayoutBuilder min(parent, cap).
        const double nestedParentWidth = 320;
        final previousPhysicalSize = tester.view.physicalSize;
        final previousDevicePixelRatio = tester.view.devicePixelRatio;
        addTearDown(() {
          tester.view.physicalSize = previousPhysicalSize;
          tester.view.devicePixelRatio = previousDevicePixelRatio;
        });
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;

        double? observedContentMaxWidth;

        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: SizedBox(
                width: nestedParentWidth,
                height: 640,
                child: CommonPageLayout(
                  title: 'Nested',
                  body: Builder(
                    builder: (context) {
                      observedContentMaxWidth = context.contentMaxWidth;
                      return const SizedBox(
                        key: Key('responsive-body-probe'),
                        width: double.infinity,
                        height: 24,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(observedContentMaxWidth, isNotNull);
        expect(
          observedContentMaxWidth!,
          greaterThan(nestedParentWidth),
          reason:
              'Viewport must be wide enough that contentMaxWidth exceeds the '
              'nested parent; otherwise this test cannot prove parent-cap logic.',
        );

        final ConstrainedBox bodyCap = tester.widget<ConstrainedBox>(
          find.ancestor(
            of: find.byType(AnimatedPadding),
            matching: find.byType(ConstrainedBox),
          ),
        );
        expect(
          bodyCap.constraints.maxWidth,
          nestedParentWidth,
          reason:
              '_ResponsiveBody must pass LayoutBuilder maxWidth down when it is '
              'narrower than contentMaxWidth (constraints go down).',
        );

        final Size probeSize = tester.getSize(
          find.byKey(const Key('responsive-body-probe')),
        );
        expect(probeSize.width, lessThanOrEqualTo(nestedParentWidth));
        expect(probeSize.width, lessThan(observedContentMaxWidth!));
      },
    );
  });
}
