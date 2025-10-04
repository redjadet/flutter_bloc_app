import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/app_config.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  test('resolveLocales returns exact match with region', () {
    final Locale? resolved = AppConfig.resolveLocales(const <Locale>[
      Locale('tr', 'TR'),
    ], AppLocalizations.supportedLocales);
    expect(resolved, const Locale('tr', 'TR'));
  });

  test('resolveLocales returns language-only match', () {
    final Locale? resolved = AppConfig.resolveLocales(const <Locale>[
      Locale('es', 'MX'),
    ], AppLocalizations.supportedLocales);
    expect(resolved?.languageCode, 'es');
  });

  test('resolveLocales falls back to English', () {
    final Locale? resolved = AppConfig.resolveLocales(const <Locale>[
      Locale('xx'),
    ], AppLocalizations.supportedLocales);
    expect(resolved, const Locale('en'));
  });

  testWidgets('createMaterialApp renders router tree', (
    WidgetTester tester,
  ) async {
    final GoRouter router = GoRouter(
      initialLocation: AppRoutes.counterPath,
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.counterPath,
          builder: (context, state) => const Text('content'),
        ),
      ],
    );

    await tester.pumpWidget(
      AppConfig.createMaterialApp(themeMode: ThemeMode.light, router: router),
    );

    await tester.pumpAndSettle();
    expect(find.text('content'), findsOneWidget);
  });
}
