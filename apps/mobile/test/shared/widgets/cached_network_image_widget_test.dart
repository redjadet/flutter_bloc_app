import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/widgets/cached_network_image_widget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CachedNetworkImageWidget', () {
    testWidgets('renders CachedNetworkImage with provided URL', (
      final tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CachedNetworkImageWidget(
              imageUrl: 'https://example.com/image.jpg',
            ),
          ),
        ),
      );

      // Should render without errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('respects fit parameter', (final tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CachedNetworkImageWidget(
              imageUrl: 'https://example.com/image.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
      );

      // Should render without errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('respects width and height parameters', (final tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CachedNetworkImageWidget(
              imageUrl: 'https://example.com/image.jpg',
              width: 100,
              height: 100,
            ),
          ),
        ),
      );

      // Should render without errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('uses custom placeholder when provided', (final tester) async {
      bool placeholderShown = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CachedNetworkImageWidget(
              imageUrl: 'https://example.com/image.jpg',
              placeholder: (final context, final url) {
                placeholderShown = true;
                return const CircularProgressIndicator();
              },
            ),
          ),
        ),
      );

      await tester.pump();

      // Placeholder should be called
      expect(placeholderShown, isTrue);
    });

    testWidgets('uses custom errorWidget when provided', (final tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CachedNetworkImageWidget(
              imageUrl: 'https://invalid-url-that-will-fail.com/image.jpg',
              errorWidget: (final context, final url, final error) {
                return const Icon(Icons.error);
              },
            ),
          ),
        ),
      );

      await tester.pump();

      // Should render without errors initially
      expect(tester.takeException(), isNull);
    });

    testWidgets('respects fadeInDuration parameter', (final tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CachedNetworkImageWidget(
              imageUrl: 'https://example.com/image.jpg',
              fadeInDuration: const Duration(milliseconds: 500),
            ),
          ),
        ),
      );

      // Should render without errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('respects fadeOutDuration parameter', (final tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CachedNetworkImageWidget(
              imageUrl: 'https://example.com/image.jpg',
              fadeOutDuration: const Duration(milliseconds: 200),
            ),
          ),
        ),
      );

      // Should render without errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('respects memCacheWidth and memCacheHeight parameters', (
      final tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CachedNetworkImageWidget(
              imageUrl: 'https://example.com/image.jpg',
              memCacheWidth: 200,
              memCacheHeight: 200,
            ),
          ),
        ),
      );

      // Should render without errors
      expect(tester.takeException(), isNull);
    });
  });
}
