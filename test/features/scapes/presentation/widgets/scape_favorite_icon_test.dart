import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/widgets/scape_favorite_icon.dart';
import 'package:flutter_bloc_app/shared/widgets/resilient_svg_asset_image.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpIcon(
    WidgetTester tester, {
    bool isFavorite = false,
    Color color = Colors.amber,
    double size = 16,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScapeFavoriteIcon(
            isFavorite: isFavorite,
            color: color,
            size: size,
          ),
        ),
      ),
    );
  }

  group('ScapeFavoriteIcon', () {
    testWidgets('renders with ResilientSvgAssetImage', (
      WidgetTester tester,
    ) async {
      await pumpIcon(tester);

      expect(find.byType(ResilientSvgAssetImage), findsOneWidget);
    });

    testWidgets('respects size parameter', (WidgetTester tester) async {
      await pumpIcon(tester, size: 24);

      final SizedBox box = tester.widget(find.byType(SizedBox).first);
      expect(box.width, 24);
      expect(box.height, 24);
    });
  });
}
