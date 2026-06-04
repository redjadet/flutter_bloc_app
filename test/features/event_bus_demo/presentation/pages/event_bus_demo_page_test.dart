import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/event_bus_demo/domain/event_bus_demo_events.dart';
import 'package:flutter_bloc_app/features/event_bus_demo/presentation/pages/event_bus_demo_page.dart';
import 'package:flutter_bloc_app/features/event_bus_demo/presentation/widgets/event_bus_demo_login_panel.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test_helpers.dart';

void main() {
  group('EventBusDemoPage', () {
    late EventBus eventBus;

    setUp(() async {
      await getIt.reset();
      eventBus = EventBus();
      getIt.registerSingleton<EventBus>(eventBus);
    });

    tearDown(() async {
      await getIt.reset(dispose: true);
    });

    testWidgets('disables login when user id is empty', (final tester) async {
      await tester.pumpWidget(
        wrapWithProviders(child: const EventBusDemoPage()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      final loginButton = tester.widget<FilledButton>(
        find.byKey(EventBusDemoLoginPanel.loginButtonKey),
      );
      expect(loginButton.onPressed, isNull);
    });

    testWidgets('login event updates home and notification panels', (
      final tester,
    ) async {
      final l10n = lookupAppLocalizations(const Locale('en'));
      tester.view.physicalSize = const Size(390, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        wrapWithProviders(child: const EventBusDemoPage()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '42');
      await tester.pump();

      await tester.tap(find.byKey(EventBusDemoLoginPanel.loginButtonKey));
      await tester.pump();

      expect(find.text(l10n.eventBusDemoHomeActive('42', 1)), findsOneWidget);
      expect(
        find.text(l10n.eventBusDemoNotificationConnected('42')),
        findsOneWidget,
      );
      expect(
        find.byKey(EventBusDemoLoginPanel.logoutButtonKey),
        findsOneWidget,
      );

      await tester.tap(find.byKey(EventBusDemoLoginPanel.logoutButtonKey));
      await tester.pump();

      expect(find.text(l10n.eventBusDemoHomeWaiting), findsOneWidget);
      expect(find.text(l10n.eventBusDemoNotificationIdle), findsOneWidget);
      expect(find.byKey(EventBusDemoLoginPanel.logoutButtonKey), findsNothing);
    });

    testWidgets('external login event updates listener panels', (
      final tester,
    ) async {
      final l10n = lookupAppLocalizations(const Locale('en'));
      tester.view.physicalSize = const Size(390, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        wrapWithProviders(child: const EventBusDemoPage()),
      );
      await tester.pumpAndSettle();

      eventBus.fire(const UserLoggedInEvent('77'));
      await tester.pumpAndSettle();

      expect(find.text(l10n.eventBusDemoHomeActive('77', 1)), findsOneWidget);
      expect(
        find.text(l10n.eventBusDemoNotificationConnected('77')),
        findsOneWidget,
      );
    });
  });
}
