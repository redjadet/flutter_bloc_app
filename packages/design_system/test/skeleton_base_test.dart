import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SkeletonBase renders child', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: const Scaffold(
          body: SkeletonBase(
            semanticLabel: 'Loading items',
            child: Text('placeholder'),
          ),
        ),
      ),
    );

    expect(find.text('placeholder'), findsOneWidget);
    expect(find.byType(SkeletonBase), findsOneWidget);
  });
}
