import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/auth/presentation/pages/logged_out_page.dart';
import 'package:flutter_bloc_app/shared/shared.dart';

void main() {
  group('LoggedOutPage', () {
    Widget buildSubject() {
      return MaterialApp(home: const LoggedOutPage());
    }

    testWidgets('renders CommonPageLayout', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(LoggedOutPage), findsOneWidget);
      expect(find.byType(CommonPageLayout), findsOneWidget);
    });

    testWidgets('displays correct title', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Logged Out'), findsOneWidget);
    });

    testWidgets('renders LoggedOutPageBody', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // LoggedOutPageBody is rendered inside CommonPageLayout
      expect(find.byType(LoggedOutPage), findsOneWidget);
    });
  });
}
