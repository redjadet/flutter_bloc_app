import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/bootstrap/web_launch_splash.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('WebLaunchSplash shows progress and starting label', (
    final WidgetTester tester,
  ) async {
    await tester.pumpWidget(const WebLaunchSplash());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Starting…'), findsOneWidget);
  });
}
