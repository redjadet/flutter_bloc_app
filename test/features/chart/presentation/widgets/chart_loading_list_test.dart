import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chart/presentation/widgets/chart_loading_list.dart';
import 'package:flutter_bloc_app/features/chart/presentation/widgets/chart_scrollable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeletonizer/skeletonizer.dart';

void main() {
  testWidgets('ChartLoadingList renders skeletonized placeholders', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ChartLoadingList())),
    );

    expect(find.byType(ChartScrollable), findsOneWidget);
    expect(
      find.byWidgetPredicate((widget) => widget is Skeletonizer),
      findsOneWidget,
    );
  });
}
