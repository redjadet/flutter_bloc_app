import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/widgets/resilient_svg_asset_image.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ResilientSvgAssetImage', () {
    Widget createWidget({
      required String assetPath,
      BoxFit fit = BoxFit.contain,
      Widget Function()? fallbackBuilder,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ResilientSvgAssetImage(
            assetPath: assetPath,
            fit: fit,
            fallbackBuilder: fallbackBuilder ?? () => const SizedBox.shrink(),
          ),
        ),
      );
    }

    testWidgets('displays fallback while loading', (tester) async {
      await tester.pumpWidget(
        createWidget(
          assetPath: 'assets/test.svg',
          fallbackBuilder: () => const Text('Loading...'),
        ),
      );

      // Initially shows fallback while FutureBuilder is waiting
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('displays fallback when asset load fails', (tester) async {
      await tester.pumpWidget(
        createWidget(
          assetPath: 'assets/nonexistent.svg',
          fallbackBuilder: () => const Text('Error'),
        ),
      );

      await tester.pumpAndSettle();

      // Should show fallback when asset doesn't exist
      expect(find.text('Error'), findsOneWidget);
    });

    testWidgets('creates widget with required parameters', (tester) async {
      const widget = ResilientSvgAssetImage(
        assetPath: 'assets/test.svg',
        fit: BoxFit.cover,
        fallbackBuilder: SizedBox.shrink,
      );

      expect(widget.assetPath, 'assets/test.svg');
      expect(widget.fit, BoxFit.cover);
      expect(widget.fallbackBuilder, isNotNull);
    });

    testWidgets('handles different BoxFit values', (tester) async {
      await tester.pumpWidget(
        createWidget(
          assetPath: 'assets/test.svg',
          fit: BoxFit.fill,
          fallbackBuilder: () => const SizedBox.shrink(),
        ),
      );

      // Widget should render without errors
      expect(find.byType(ResilientSvgAssetImage), findsOneWidget);
    });

    testWidgets('calls fallbackBuilder when provided', (tester) async {
      bool fallbackCalled = false;
      await tester.pumpWidget(
        createWidget(
          assetPath: 'assets/nonexistent.svg',
          fallbackBuilder: () {
            fallbackCalled = true;
            return const Text('Fallback');
          },
        ),
      );

      await tester.pumpAndSettle();

      expect(fallbackCalled, isTrue);
      expect(find.text('Fallback'), findsOneWidget);
    });
  });
}
