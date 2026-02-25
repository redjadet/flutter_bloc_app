import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/theme/mix_app_theme.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_bloc_app/shared/widgets/common_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mix/mix.dart';

void main() {
  group('CommonCard', () {
    Future<void> pumpCommonCard(
      final WidgetTester tester, {
      required final CommonCard card,
      final ThemeData? theme,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (final context) => MixTheme(
              data: buildAppMixThemeData(context),
              child: Scaffold(body: card),
            ),
          ),
        ),
      );
    }

    testWidgets('uses Mix token defaults for style and padding', (
      final tester,
    ) async {
      const childKey = Key('common_card_default_child');
      final theme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      );

      await pumpCommonCard(
        tester,
        theme: theme,
        card: const CommonCard(child: SizedBox.shrink(key: childKey)),
      );

      final cardWidget = tester.widget<Card>(find.byType(Card));
      expect(cardWidget.color, theme.colorScheme.surface);
      expect(cardWidget.elevation, 1);

      final shape = cardWidget.shape as RoundedRectangleBorder;
      final radius = shape.borderRadius as BorderRadius;
      expect(radius.topLeft.x, UI.radiusM);
      expect(radius.topRight.x, UI.radiusM);

      final paddingWidget = tester.widget<Padding>(
        find
            .ancestor(of: find.byKey(childKey), matching: find.byType(Padding))
            .first,
      );
      expect(
        paddingWidget.padding,
        EdgeInsets.only(
          top: UI.cardPadV,
          bottom: UI.cardPadV,
          left: UI.cardPadH,
          right: UI.cardPadH,
        ),
      );
    });

    testWidgets('respects explicit overrides', (final tester) async {
      const childKey = Key('common_card_override_child');
      final customShape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      );
      const customMargin = EdgeInsets.all(10);
      const customPadding = EdgeInsets.symmetric(horizontal: 11, vertical: 9);
      final customColor = Colors.orange;

      await pumpCommonCard(
        tester,
        card: CommonCard(
          color: customColor,
          elevation: 5,
          margin: customMargin,
          shape: customShape,
          padding: customPadding,
          child: const SizedBox.shrink(key: childKey),
        ),
      );

      final cardWidget = tester.widget<Card>(find.byType(Card));
      expect(cardWidget.color, customColor);
      expect(cardWidget.elevation, 5);
      expect(cardWidget.margin, customMargin);
      expect(cardWidget.shape, customShape);

      final paddingWidget = tester.widget<Padding>(
        find
            .ancestor(of: find.byKey(childKey), matching: find.byType(Padding))
            .first,
      );
      expect(paddingWidget.padding, customPadding);
    });
  });
}
