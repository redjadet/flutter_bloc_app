import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/widgets/icon_label_row.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression: Row+Icon+Text must use [IconLabelRow] (or Flexible/Expanded)
/// to avoid RenderFlex overflow on narrow widths. See tool/check_row_text_overflow.sh.
void main() {
  testWidgets('IconLabelRow does not overflow at narrow width', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: Builder(
          builder: (BuildContext context) {
            return SizedBox(
              width: 200,
              child: IconLabelRow(
                icon: Icons.star,
                label: 'A very long label that would overflow in a raw Row',
              ),
            );
          },
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(IconLabelRow), findsOneWidget);
  });

  testWidgets('IconLabelRow without icon does not overflow at narrow width', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: SizedBox(width: 150, child: IconLabelRow(label: 'Label only')),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(IconLabelRow), findsOneWidget);
  });
}
