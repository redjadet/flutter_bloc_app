import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/flavor.dart';
import 'package:flutter_bloc_app/shared/responsive/responsive_scope.dart';
import 'package:flutter_bloc_app/shared/widgets/flavor_badge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlavorBadge', () {
    testWidgets('renders nothing for prod flavor', (final tester) async {
      FlavorManager.current = Flavor.prod;

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScope(child: Scaffold(body: const FlavorBadge())),
        ),
      );

      expect(find.byType(FlavorBadge), findsOneWidget);
      expect(find.byType(Container), findsNothing);
    });

    testWidgets('renders badge for dev flavor', (final tester) async {
      FlavorManager.current = Flavor.dev;

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScope(child: Scaffold(body: const FlavorBadge())),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.text('DEV'), findsOneWidget);
    });

    testWidgets('renders badge for staging flavor', (final tester) async {
      FlavorManager.current = Flavor.staging;

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScope(child: Scaffold(body: const FlavorBadge())),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.text('STG'), findsOneWidget);
    });

    testWidgets('renders badge for qa flavor', (final tester) async {
      FlavorManager.current = Flavor.qa;

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScope(child: Scaffold(body: const FlavorBadge())),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.text('QA'), findsOneWidget);
    });

    testWidgets('renders badge for beta flavor', (final tester) async {
      FlavorManager.current = Flavor.beta;

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScope(child: Scaffold(body: const FlavorBadge())),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.text('BETA'), findsOneWidget);
    });

    testWidgets('applies correct styling', (final tester) async {
      FlavorManager.current = Flavor.dev;

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScope(child: Scaffold(body: const FlavorBadge())),
        ),
      );

      final Container container = tester.widget(find.byType(Container));
      expect(container.decoration, isA<BoxDecoration>());
      final BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, isNotNull);
      expect(decoration.border, isNotNull);
    });
  });
}
