import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('text scaling smoke test at 1.3x', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: const MaterialApp(
          home: CommonPageLayout(
            title: 'Scaling Test',
            body: Column(
              children: [Text('Primary content'), Text('Secondary content')],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Scaling Test'), findsOneWidget);
    expect(find.text('Primary content'), findsOneWidget);
    expect(find.text('Secondary content'), findsOneWidget);
  });
}
