import 'package:flutter_bloc_app/features/chart/presentation/widgets/chart_message_list.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
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
