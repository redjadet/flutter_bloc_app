import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/app_config.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/core/theme/app_theme.dart';
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

  test('resolveLocales supports Arabic', () {
    final Locale? resolved = AppConfig.resolveLocales(const <Locale>[
      Locale('ar'),
    ], AppLocalizations.supportedLocales);
    expect(resolved, const Locale('ar'));
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

  testWidgets('Arabic locale applies bundled Cairo theme', (
    WidgetTester tester,
  ) async {
    late String? bodyFontFamily;
    final GoRouter router = GoRouter(
      initialLocation: AppRoutes.counterPath,
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.counterPath,
          builder: (context, state) => Builder(
            builder: (context) {
              bodyFontFamily = Theme.of(
                context,
              ).textTheme.bodyMedium?.fontFamily;
              return const Text('content');
            },
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      AppConfig.createMaterialApp(
        themeMode: ThemeMode.light,
        router: router,
        locale: const Locale('ar'),
      ),
    );

    await tester.pumpAndSettle();
    expect(bodyFontFamily, AppTheme.arabicFontFamily);
  });
}
