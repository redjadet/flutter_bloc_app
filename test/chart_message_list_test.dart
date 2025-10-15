import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chart/presentation/widgets/chart_message_list.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    UI.resetScreenUtilReady();
  });

  testWidgets('ChartMessageList displays provided message', (
    WidgetTester tester,
  ) async {
    const String message = 'No data available';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ChartMessageList(message: message)),
      ),
    );

    expect(find.text(message), findsOneWidget);
  });
}
