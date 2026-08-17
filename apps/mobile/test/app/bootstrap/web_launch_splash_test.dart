import 'package:flutter_bloc_app/app/bootstrap/web_launch_splash.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('WebLaunchSplash shows progress and starting label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const WebLaunchSplash());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Starting…'), findsOneWidget);
  });
}
