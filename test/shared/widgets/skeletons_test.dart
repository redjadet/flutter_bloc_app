import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/widgets/skeletons/skeleton_card.dart';
import 'package:flutter_bloc_app/shared/widgets/skeletons/skeleton_grid_item.dart';
import 'package:flutter_bloc_app/shared/widgets/skeletons/skeleton_list_tile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SkeletonListTile', () {
    testWidgets('renders semantics label and repaint boundary', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SkeletonListTile())),
      );

      expect(find.byType(SkeletonListTile), findsOneWidget);
      expect(find.bySemanticsLabel('Loading content'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SkeletonListTile),
          matching: find.byType(RepaintBoundary),
        ),
        findsOneWidget,
      );
    });

    testWidgets('omits avatar when disabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SkeletonListTile(hasAvatar: false)),
        ),
      );

      final avatarFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration! as BoxDecoration;
          return decoration.shape == BoxShape.circle;
        }
        return false;
      });

      expect(avatarFinder, findsNothing);
    });
  });

  group('SkeletonGridItem', () {
    testWidgets('renders aspect ratio without overlay by default', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SkeletonGridItem())),
      );

      final aspectRatio = tester.widget<AspectRatio>(find.byType(AspectRatio));
      expect(aspectRatio.aspectRatio, equals(1.0));
      expect(find.bySemanticsLabel('Loading content'), findsOneWidget);
      expect(aspectRatio.child, isA<DecoratedBox>());

      final decoratedBox = aspectRatio.child! as DecoratedBox;
      expect(decoratedBox.child, isNull);
    });

    testWidgets('renders overlay when enabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SkeletonGridItem(hasOverlay: true)),
        ),
      );

      expect(find.bySemanticsLabel('Loading content'), findsOneWidget);
      final aspectRatio = tester.widget<AspectRatio>(find.byType(AspectRatio));
      expect(aspectRatio.child, isA<DecoratedBox>());

      final decoratedBox = aspectRatio.child! as DecoratedBox;
      expect(decoratedBox.child, isA<Stack>());
    });
  });

  group('SkeletonCard', () {
    testWidgets('renders semantics label and repaint boundary', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SkeletonCard())),
      );

      expect(find.byType(SkeletonCard), findsOneWidget);
      expect(find.bySemanticsLabel('Loading content'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SkeletonCard),
          matching: find.byType(RepaintBoundary),
        ),
        findsOneWidget,
      );
    });

    testWidgets('omits image section when disabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SkeletonCard(hasImage: false))),
      );

      expect(find.byType(Expanded), findsNothing);
    });
  });
}
