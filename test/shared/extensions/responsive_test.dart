import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ResponsiveContext', () {
    Widget createTestWidget({
      required double width,
      required Orientation orientation,
      required Widget Function(BuildContext) builder,
    }) {
      return MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(width, orientation == Orientation.portrait ? 800 : 400),
          ),
          child: Builder(builder: builder),
        ),
      );
    }

    testWidgets('isMobile returns true for small screens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          width: 300,
          orientation: Orientation.portrait,
          builder: (context) {
            expect(context.isMobile, isTrue);
            expect(context.isTabletOrLarger, isFalse);
            expect(context.isDesktop, isFalse);
            return const Text('Test');
          },
        ),
      );
    });

    testWidgets('isTabletOrLarger returns true for medium screens', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          width: 800,
          orientation: Orientation.portrait,
          builder: (context) {
            expect(context.isMobile, isFalse);
            expect(context.isTabletOrLarger, isTrue);
            expect(context.isDesktop, isFalse);
            return const Text('Test');
          },
        ),
      );
    });

    testWidgets('isDesktop returns true for large screens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          width: 1200,
          orientation: Orientation.portrait,
          builder: (context) {
            expect(context.isMobile, isFalse);
            expect(context.isTabletOrLarger, isTrue);
            expect(context.isDesktop, isTrue);
            return const Text('Test');
          },
        ),
      );
    });

    testWidgets('isPortrait returns correct orientation', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          width: 400,
          orientation: Orientation.portrait,
          builder: (context) {
            expect(context.isPortrait, isTrue);
            expect(context.isLandscape, isFalse);
            return const Text('Test');
          },
        ),
      );
    });

    testWidgets('isLandscape returns correct orientation', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          width: 800,
          orientation: Orientation.landscape,
          builder: (context) {
            expect(context.isPortrait, isFalse);
            expect(context.isLandscape, isTrue);
            return const Text('Test');
          },
        ),
      );
    });

    testWidgets('pageHorizontalPadding returns correct values', (tester) async {
      // Mobile
      await tester.pumpWidget(
        createTestWidget(
          width: 300,
          orientation: Orientation.portrait,
          builder: (context) {
            expect(context.pageHorizontalPadding, greaterThan(0));
            return const Text('Test');
          },
        ),
      );

      // Tablet
      await tester.pumpWidget(
        createTestWidget(
          width: 800,
          orientation: Orientation.portrait,
          builder: (context) {
            expect(context.pageHorizontalPadding, greaterThan(0));
            return const Text('Test');
          },
        ),
      );

      // Desktop
      await tester.pumpWidget(
        createTestWidget(
          width: 1200,
          orientation: Orientation.portrait,
          builder: (context) {
            expect(context.pageHorizontalPadding, greaterThan(0));
            return const Text('Test');
          },
        ),
      );
    });

    testWidgets('pageVerticalPadding returns correct values', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          width: 400,
          orientation: Orientation.portrait,
          builder: (context) {
            expect(context.pageVerticalPadding, greaterThan(0));
            return const Text('Test');
          },
        ),
      );
    });

    testWidgets('contentMaxWidth returns correct constraints', (tester) async {
      // Mobile
      await tester.pumpWidget(
        createTestWidget(
          width: 300,
          orientation: Orientation.portrait,
          builder: (context) {
            expect(context.contentMaxWidth, greaterThan(0));
            return const Text('Test');
          },
        ),
      );

      // Desktop
      await tester.pumpWidget(
        createTestWidget(
          width: 1200,
          orientation: Orientation.portrait,
          builder: (context) {
            expect(context.contentMaxWidth, greaterThan(0));
            return const Text('Test');
          },
        ),
      );
    });

    testWidgets('barMaxWidth returns correct constraints', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          width: 400,
          orientation: Orientation.portrait,
          builder: (context) {
            expect(context.barMaxWidth, greaterThan(0));
            return const Text('Test');
          },
        ),
      );
    });

    testWidgets('pagePadding returns EdgeInsets with correct values', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          width: 400,
          orientation: Orientation.portrait,
          builder: (context) {
            final padding = context.pagePadding;
            expect(padding, isA<EdgeInsets>());
            expect(padding.left, greaterThan(0));
            expect(padding.right, greaterThan(0));
            expect(padding.top, greaterThan(0));
            expect(padding.bottom, greaterThanOrEqualTo(0));
            return const Text('Test');
          },
        ),
      );
    });

    testWidgets('responsiveFontSize returns appropriate values', (
      tester,
    ) async {
      // Mobile
      await tester.pumpWidget(
        createTestWidget(
          width: 300,
          orientation: Orientation.portrait,
          builder: (context) {
            expect(context.responsiveFontSize, greaterThan(0));
            return const Text('Test');
          },
        ),
      );

      // Desktop
      await tester.pumpWidget(
        createTestWidget(
          width: 1200,
          orientation: Orientation.portrait,
          builder: (context) {
            expect(context.responsiveFontSize, greaterThan(0));
            return const Text('Test');
          },
        ),
      );
    });

    testWidgets('responsiveIconSize returns appropriate values', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          width: 400,
          orientation: Orientation.portrait,
          builder: (context) {
            expect(context.responsiveIconSize, greaterThan(0));
            return const Text('Test');
          },
        ),
      );
    });

    testWidgets('gridColumns returns correct values', (tester) async {
      // Mobile
      await tester.pumpWidget(
        createTestWidget(
          width: 300,
          orientation: Orientation.portrait,
          builder: (context) {
            expect(context.gridColumns, equals(2));
            return const Text('Test');
          },
        ),
      );

      // Tablet
      await tester.pumpWidget(
        createTestWidget(
          width: 800,
          orientation: Orientation.portrait,
          builder: (context) {
            expect(context.gridColumns, equals(3));
            return const Text('Test');
          },
        ),
      );

      // Desktop
      await tester.pumpWidget(
        createTestWidget(
          width: 1200,
          orientation: Orientation.portrait,
          builder: (context) {
            expect(context.gridColumns, equals(4));
            return const Text('Test');
          },
        ),
      );
    });

    testWidgets('responsiveGap returns appropriate values', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          width: 400,
          orientation: Orientation.portrait,
          builder: (context) {
            expect(context.responsiveGap, greaterThan(0));
            return const Text('Test');
          },
        ),
      );
    });

    testWidgets('responsiveCardPadding returns appropriate values', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          width: 400,
          orientation: Orientation.portrait,
          builder: (context) {
            expect(context.responsiveCardPadding, greaterThan(0));
            return const Text('Test');
          },
        ),
      );
    });

    testWidgets('responsiveButtonHeight returns appropriate values', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          width: 400,
          orientation: Orientation.portrait,
          builder: (context) {
            expect(context.responsiveButtonHeight, greaterThan(0));
            return const Text('Test');
          },
        ),
      );
    });

    testWidgets('responsiveButtonPadding returns appropriate values', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          width: 400,
          orientation: Orientation.portrait,
          builder: (context) {
            expect(context.responsiveButtonPadding, greaterThan(0));
            return const Text('Test');
          },
        ),
      );
    });

    testWidgets('responsive text sizes return appropriate values', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          width: 400,
          orientation: Orientation.portrait,
          builder: (context) {
            expect(context.responsiveHeadlineSize, greaterThan(0));
            expect(context.responsiveTitleSize, greaterThan(0));
            expect(context.responsiveBodySize, greaterThan(0));
            expect(context.responsiveCaptionSize, greaterThan(0));
            return const Text('Test');
          },
        ),
      );
    });

    testWidgets('responsive margins return EdgeInsets', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          width: 400,
          orientation: Orientation.portrait,
          builder: (context) {
            final pageMargin = context.responsivePageMargin;
            final cardMargin = context.responsiveCardMargin;
            final listPadding = context.responsiveListPadding;

            expect(pageMargin, isA<EdgeInsets>());
            expect(cardMargin, isA<EdgeInsets>());
            expect(listPadding, isA<EdgeInsets>());

            return const Text('Test');
          },
        ),
      );
    });

    testWidgets('responsive border radius returns appropriate values', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          width: 400,
          orientation: Orientation.portrait,
          builder: (context) {
            expect(context.responsiveBorderRadius, greaterThan(0));
            expect(context.responsiveCardRadius, greaterThan(0));
            return const Text('Test');
          },
        ),
      );
    });

    testWidgets('responsive elevation returns appropriate values', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          width: 400,
          orientation: Orientation.portrait,
          builder: (context) {
            expect(context.responsiveElevation, greaterThan(0));
            expect(context.responsiveCardElevation, greaterThanOrEqualTo(0));
            return const Text('Test');
          },
        ),
      );
    });

    testWidgets('safe area helpers return correct values', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          width: 400,
          orientation: Orientation.portrait,
          builder: (context) {
            expect(context.bottomInset, greaterThanOrEqualTo(0));
            expect(context.topInset, greaterThanOrEqualTo(0));
            expect(context.safeAreaInsets, isA<EdgeInsets>());
            return const Text('Test');
          },
        ),
      );
    });

    testWidgets('works with ScreenUtil disabled', (tester) async {
      // Reset ScreenUtil state
      UI.screenUtilReady = false;

      await tester.pumpWidget(
        createTestWidget(
          width: 400,
          orientation: Orientation.portrait,
          builder: (context) {
            // Should not throw and return reasonable values
            expect(context.responsiveFontSize, greaterThan(0));
            expect(context.responsiveIconSize, greaterThan(0));
            expect(context.responsiveGap, greaterThan(0));
            return const Text('Test');
          },
        ),
      );
    });
  });
}
